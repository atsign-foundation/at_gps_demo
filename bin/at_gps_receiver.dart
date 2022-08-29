import 'dart:convert';
import 'dart:io';
import 'dart:async';

// external packages
import 'package:args/args.dart';
import 'package:logging/src/level.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// @platform packages
import 'package:at_client/at_client.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';

import 'package:at_gps_demo/home_directory.dart';
import 'package:at_gps_demo/check_file_exists.dart';

var pongCount = 0; // Pong counter
var mqttSession = MqttServerClient('test.mosquitto.org', '');

void main(List<String> args) async {
  //starting secondary in a zone
  var logger = AtSignLogger('GPS reciever ');
  runZonedGuarded(() async {
    await gpsMqtt(args);
  }, (error, stackTrace) {
    logger.severe('Uncaught error: $error');
    logger.severe(stackTrace.toString());
  });
}

Future<void> gpsMqtt(List<String> args) async {
  String mqttIP;
  String mqttTopic;
  String mqttUsername;
  String nameSpace = 'ai6bh';
  String deviceName;

  InternetAddress target;
  final AtSignLogger logger = AtSignLogger(' GPS rec ');
  logger.hierarchicalLoggingEnabled = true;
  logger.logger.level = Level.WARNING;

  var parser = ArgParser();
// Args
  parser.addOption('key-file',
      abbr: 'k', mandatory: false, help: 'transmitters atSign\'s atKeys file if not in ~/.atsign/keys/');
  parser.addOption('receiver-atsign', abbr: 'r', mandatory: true, help: '@sign that recieves notifications');
  parser.addOption('data-from-atsign', abbr: 'f', mandatory: true, help: 'Source atSign');
  parser.addOption('device-name', abbr: 'n', mandatory: true, help: 'Device name, used as AtKey:key');
  parser.addOption('mqtt-host', abbr: 'm', mandatory: true, help: 'MQQT server hostname');
  parser.addOption('mqtt-username', abbr: 'u', mandatory: true, help: 'MQQT server username');
  parser.addOption('mqtt-topic', abbr: 't', mandatory: true, help: 'MQTT subjectname');
  parser.addFlag('verbose', abbr: 'v', help: 'More logging');

  // Check the arguments
  dynamic results;
  String atsignFile;

  String receivingAtsign = 'unknown';
  String fromAtsign = 'unknown';
  String? homeDirectory = getHomeDirectory();

  try {
    // Arg check
    results = parser.parse(args);
    // Find @sign key file
    receivingAtsign = results['receiver-atsign'];
    fromAtsign = results['data-from-atsign'];
    mqttIP = results['mqtt-host'];
    mqttUsername = results['mqtt-username'];
    mqttTopic = results['mqtt-topic'];
    deviceName = results['device-name'];

    var targetlist = await InternetAddress.lookup(mqttIP);
    target = targetlist[0];

    if (results['key-file'] != null) {
      atsignFile = results['key-file'];
    } else {
      atsignFile = '${receivingAtsign}_key.atKeys';
      atsignFile = '$homeDirectory/.atsign/keys/$atsignFile';
    }
    // Check atKeyFile selected exists
    if (!await fileExists(atsignFile)) {
      throw ('\n Unable to find .atKeys file : $atsignFile');
    }
  } catch (e) {
    print(parser.usage);
    print(e);
    exit(1);
  }

// Now on to the @platform startup
  AtSignLogger.root_level = 'WARNING';
  if (results['verbose']) {
    logger.logger.level = Level.INFO;

    AtSignLogger.root_level = 'INFO';
  }

  //onboarding preference builder can be used to set onboardingService parameters
  AtOnboardingPreference atOnboardingConfig = AtOnboardingPreference()
    ..hiveStoragePath = '$homeDirectory/.$nameSpace/$receivingAtsign/$deviceName/storage'
    ..namespace = nameSpace
    ..downloadPath = '$homeDirectory/.$nameSpace/files'
    ..isLocalStoreRequired = true
    ..commitLogPath = '$homeDirectory/.$nameSpace/$receivingAtsign/$deviceName/storage/commitLog'
    ..atKeysFilePath = atsignFile;

  AtOnboardingService onboardingService = AtOnboardingServiceImpl(receivingAtsign, atOnboardingConfig);

  await onboardingService.authenticate();

  // var atClient = await onboardingService.getAtClient();

  AtClientManager atClientManager = AtClientManager.getInstance();

  NotificationService notificationService = atClientManager.notificationService;

// Keep an eye on connectivity and report failures if we see them
  ConnectivityListener().subscribe().listen((isConnected) {
    if (isConnected) {
      logger.warning('connection available');
    } else {
      logger.warning('connection lost');
    }
  });

//Waiting for sync breaks stuff for now
// As we only use notifications thats just fine
  bool syncComplete = false;
  void onSyncDone(syncResult) {
    logger.info("syncResult.syncStatus: ${syncResult.syncStatus}");
    logger.info("syncResult.lastSyncedOn ${syncResult.lastSyncedOn}");
    syncComplete = true;
  }

  // Wait for initial sync to complete
  logger.info("Waiting for initial sync");
  stdout.write("Syncing your data.");
  syncComplete = false;
  atClientManager.syncService.sync(onDone: onSyncDone);
  while (!syncComplete) {
    await Future.delayed(Duration(milliseconds: 500));
    stderr.write(".");
  }

// Set up MQTT
  mqttSession = MqttServerClient(mqttIP, deviceName, maxConnectionAttempts: 10);
  final builder = MqttClientPayloadBuilder();

  mqttSession.setProtocolV311();
  mqttSession.keepAlivePeriod = 20;
  mqttSession.autoReconnect = true;
  // Pong Callback
  void pong() {
    logger.info('Mosquitto Ping response client callback invoked');
    pongCount++;
  }

  mqttSession.pongCallback = pong;

  // await mqttSession.connect(mqttUsername, 'KRYZ');
  // print(mqttSession.connectionStatus);

  /// Create a connection message to use or use the default one. The default one sets the
  /// client identifier, any supplied username/password and clean session,
  /// an example of a specific one below.
  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      // .withWillTopic('willtopic') // If you set this you must set a will message
      // .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .authenticateAs(mqttUsername, '')
      .withWillQos(MqttQos.atLeastOnce);
  logger.info('Mosquitto client connecting....');
  mqttSession.connectionMessage = connMess;

  /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
  /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
  /// never send malformed messages.
  try {
    await mqttSession.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    logger.severe(' Mosquitto client exception - $e');
    mqttSession.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    logger.severe(' Mosquitto socket exception - $e');
    mqttSession.disconnect();
  }

  /// Check we are connected
  if (mqttSession.connectionStatus!.state == MqttConnectionState.connected) {
    logger.info(' Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    logger.severe(' Mosquitto client connection failed - disconnecting, status is ${mqttSession.connectionStatus}');
    mqttSession.disconnect();
    exit(-1);
  }

  //We only want recent events
  // Thsi will be done in the atPlatform soon!
  //
  int lastTime = 0;
// Subscribe to the Text messages
// Note this is not an atKey but a text message being sent
  notificationService.subscribe(regex: '$receivingAtsign:{"device":"$deviceName"', shouldDecrypt: true).listen(
      ((notification) async {
    String? sendingAtsign = notification.from;
    String? json = notification.key;
    json = json.replaceFirst('$receivingAtsign:', '');
    logger.info(json);
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    var decodeJson = jsonDecode(json.toString());
    int timeSent = int.parse(decodeJson['Time']);
    int timeDelay = timeNow - timeSent;
    if (timeSent > lastTime) {
      lastTime = timeSent;
      logger.info('Time Delay: $timeDelay');
      decodeJson['Time'] = '${timeDelay.toString()} ms';
      String sendJson = jsonEncode(decodeJson);
      if (notification.from == fromAtsign) {
        logger.info('Text update recieved from $sendingAtsign');

        await mqttSession.connect();
        if (mqttSession.connectionStatus!.state == MqttConnectionState.connected) {
          logger.info('Mosquitto client connected sending message');
          mqttSession.publishMessage(mqttTopic, MqttQos.atMostOnce, builder.addString(sendJson).payload!,
              retain: false);
          builder.clear();
        } else {
          await mqttSession.connect();
        }
      }
    }
  }),
      onError: (e) => logger.severe('Notification Failed:' + e.toString()),
      onDone: () => logger.info('Notification listener stopped'));
}
