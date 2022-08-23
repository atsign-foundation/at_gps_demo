import 'dart:convert';
import 'dart:io';

// external packages
import 'package:args/args.dart';
import 'package:logging/src/level.dart';
// @platform packages
import 'package:at_client/at_client.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
// Local Packages
import 'package:at_gps_demo/home_directory.dart';
import 'package:at_gps_demo/check_file_exists.dart';

void main(List<String> args) async {
  int port = 2947;
  List<int> dataBuffer = [];
  final AtSignLogger logger = AtSignLogger(' GPS send ');
  logger.hierarchicalLoggingEnabled = true;
  logger.logger.level = Level.SHOUT;

  var parser = ArgParser();
// Args
  parser.addOption('key-file',
      abbr: 'k',
      mandatory: false,
      help: 'This device\'s atSign\'s atKeys file if not in ~/.atsign/keys/');
  parser.addOption('atsign', abbr: 'a', mandatory: true, help: 'Your atSign');
  parser.addOption('toatsign',
      abbr: 't', mandatory: true, help: 'Send data to this atSign');
  parser.addOption('port',
      abbr: 'p',
      mandatory: false,
      help: 'Alternative port for GPS data',
      defaultsTo: '2947');
  parser.addOption('device-name',
      abbr: 'n', mandatory: true, help: 'Device name, used as AtKey:key');

  parser.addFlag('verbose', abbr: 'v', help: 'More logging');

// Check the arguments
  dynamic results;
  String atsignFile;
  String fromAtsign = 'unknown';
  String toAtsign = 'unknown';
  String deviceName = 'unknown';
  String? homeDirectory = getHomeDirectory();
  String nameSpace = 'ai6bh';
  String rootDomain = 'root.atsign.org';

  try {
    // Arg check
    results = parser.parse(args);
    // Find @sign key file
    fromAtsign = results['atsign'];
    toAtsign = results['toatsign'];
    deviceName = results['device-name'];

    if (results['key-file'] != null) {
      atsignFile = results['key-file'];
    } else {
      atsignFile = '${fromAtsign}_key.atKeys';
      atsignFile = '$homeDirectory/.atsign/keys/$atsignFile';
    }
    // Check atKeyFile selected exists
    if (!await fileExists(atsignFile)) {
      throw ('\n Unable to find .atKeys file : $atsignFile');
    }
    port = int.parse(results['port']);
    if ((port < 1024) | (port > 65535)) {
      throw ('\n port must be greater than 1024 and less than 65535');
    }
  } catch (e) {
    print(parser.usage);
    print(e);
    exit(1);
  }

// Now on to the @platform startup
  AtSignLogger.root_level = 'SHOUT';
  if (results['verbose']) {
    logger.logger.level = Level.INFO;

    AtSignLogger.root_level = 'INFO';
  }

  //onboarding preference builder can be used to set onboardingService parameters
  AtOnboardingPreference atOnboardingConfig = AtOnboardingPreference()
    ..hiveStoragePath =
        '$homeDirectory/.$nameSpace/$fromAtsign/$deviceName/storage'
    ..namespace = nameSpace
    ..downloadPath = '$homeDirectory/.$nameSpace/files'
    ..isLocalStoreRequired = true
    ..commitLogPath =
        '$homeDirectory/.$nameSpace/$fromAtsign/$deviceName/storage/commitLog'
    ..rootDomain = rootDomain
    ..atKeysFilePath = atsignFile;
  AtOnboardingService onboardingService =
      AtOnboardingServiceImpl(fromAtsign, atOnboardingConfig);
  await onboardingService.authenticate();
  AtClient? atClient = await onboardingService.getAtClient();
  AtClientManager atClientManager = AtClientManager.getInstance();
  NotificationService notificationService = atClientManager.notificationService;

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

  var socket = await Socket.connect('localhost', port);
  logger.info('Client connected');

  try {
    socket.listen((List<int> event) {
      dataBuffer = bufferMe(event, dataBuffer, fromAtsign, toAtsign, nameSpace,
          deviceName, notificationService, logger);
    });

    var send = '?WATCH={"enable":true,"json":true};';
    socket.writeln(send);
  } on Exception catch (exception) {
    print('Unable to connect to server:  On port $port : $exception');
  } catch (error) {
    print('Errors occured: $error');
  }
}

List<int> bufferMe(
    data,
    List<int> dataBuffer,
    String fromAtsign,
    String toAtsign,
    String nameSpace,
    String deviceName,
    NotificationService notificationService,
    AtSignLogger logger) {
  dataBuffer.addAll(data);
  String query = utf8.decode(dataBuffer);
  if (!query.contains('"lat"') || !query.contains('"lon"')) {
    // the first line just gives us a version number
    // we will ignore and reset the buffer
    dataBuffer.length = 0;
  } else {
    // We might get multiple lines in a data packet
    // so let's split them
    LineSplitter ls = LineSplitter();
    List<String> lines = ls.convert(query);
    for (var i = 0; i < lines.length; i++) {
      // print('Line $i: ${lines[i]}');
      query = lines[i];
      try {
        query = query.trimRight();
        query = query.trimLeft();
        var json = jsonDecode(query.toString());
        // temp line for demo's
        json['speed'] = json['speed'] * 10;
        Map send = {};
        send['device'] = deviceName;
        send['latitude'] = (json['lat'].toString());
        send['longitude'] = (json['lon'].toString());
        send['Speed'] = (json['speed'].toString());
        send['Time'] = DateTime.now().millisecondsSinceEpoch.toString();

        var sender = jsonEncode(send);
        print(sender);
        sendGps(fromAtsign, toAtsign, nameSpace, deviceName,
            notificationService, logger, sender);
      } catch (e) {
        print(e.toString());
      }
      // Reset the buffer
      dataBuffer.length = 0;
    }
  }
  return (dataBuffer);
}

void sendGps(
    String fromAtsign,
    String toAtsign,
    String nameSpace,
    String deviceName,
    NotificationService notificationService,
    AtSignLogger logger,
    String input) async {
  if (!(input == "")) {
    try {
     await notificationService.notify(
          NotificationParams.forText(input, toAtsign, shouldEncrypt: true),
          onSuccess: (notification) {
        logger.info('SUCCESS:$notification');
      }, onError: (notification) {
        logger.info('ERROR:$notification');
      }, onSentToSecondary: (notification) {
        logger.info('SENT:$notification');
      }, waitForFinalDeliveryStatus: false);
    } catch (e) {
      logger.severe(e.toString());
    }
  }
}
