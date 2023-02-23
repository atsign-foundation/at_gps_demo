import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'package:gpsapp/models/vehiclemodel.dart';
import 'package:gpsapp/screens/onboarding_screen.dart';

import '../vehicle_lookup.dart';
import '../widgets/Gaugewidget.dart';

// * Once the onboarding process is completed you will be taken to this screen
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  static const String id = '/home';

  final transmitter = Vehicle(stationName: 'stationName', frequency: 'frequency', ip: 'ip');

  @override
  Widget build(BuildContext context) {
    // * Getting the AtClientManager instance to use below
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nautel Meter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Nautel Meter', vehicle: transmitter),
      routes: {
        HomeScreen.id: (_) => HomeScreen(),
        OnboardingScreen.id: (_) => const OnboardingScreen(),
        //Next.id: (_) => const Next(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title, required this.vehicle}) : super(key: key);
  final Vehicle vehicle;
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    String deviceName = 'KRYZ';
    String nameSpace = 'kryz_9850';
    if (kIsWeb) {
      connectWs();
    } else {
      AtClientManager atClientManager = AtClientManager.getInstance();
      String? atSign = atClientManager.atClient.getCurrentAtSign();
      NotificationService notificationService = atClientManager.atClient.notificationService;

      notificationService
          .subscribe(regex: '$atSign:{"stationName":"$deviceName"', shouldDecrypt: true)
          .listen(((notification) async {
        print(notification.toString());
        String? json = notification.key;
        json = json.replaceFirst('$atSign:', '');
        if (notification.from == '@$nameSpace') {
          print(json);
          lookupTransmitter(widget.vehicle, json);
          setState(() {});
        }
      }));
    }
  }

  void connectWs() {
    var channel = WebSocketChannel.connect(Uri.parse('wss://ws.kryzradio.org'));
    channel.stream.listen((message) {
      var json = message;
      lookupTransmitter(widget.vehicle, json);
      setState(() {});
    },
        // reconnnect if the WS gets disconnected (yay!)
        onDone: connectWs);
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    int _gridRows = 1;
    if (_width > _height) {
      _gridRows = 2;
    } else {
      _gridRows = 1;
    }
    if (!kIsWeb) {
      return Scaffold(
        appBar: NewGradientAppBar(
          gradient:
              const LinearGradient(colors: [Color.fromARGB(255, 173, 83, 78), Color.fromARGB(255, 108, 169, 197)]),
          title: AutoSizeText(
            widget.vehicle.stationName.toString() +
                " " +
                widget.vehicle.frequency.toString() +
                ' ' +
                DateFormat.Md().add_jms().format(DateTime.parse(widget.vehicle.date.toString()).toLocal()).toString(),
            minFontSize: 3,
          ),
          actions: [
            PopupMenuButton<String>(
              color: const Color.fromARGB(255, 108, 169, 197),
              //padding: const EdgeInsets.symmetric(horizontal: 10),
              icon: const Icon(
                Icons.menu,
                size: 20,
                color: Colors.black,
              ),
              onSelected: (String result) {
                switch (result) {
                  case 'Exit':
                    exit(0);
                  case 'Back':
                    setState(() {
                      Navigator.pushNamed(context, OnboardingScreen.id);
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  height: 20,
                  value: 'Back',
                  child: Text(
                    'Back',
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 5,
                        backgroundColor: Color.fromARGB(255, 108, 169, 197),
                        color: Colors.black),
                  ),
                ),
                const PopupMenuItem<String>(
                  height: 20,
                  value: 'Exit',
                  child: Text(
                    'Exit',
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 5,
                        backgroundColor: Color.fromARGB(255, 108, 169, 197),
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          // ignore: prefer_const_constructors
          decoration: BoxDecoration(
            color: Colors.white70,
            gradient: _gridRows > 1
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 240, 181, 178), Color.fromARGB(255, 171, 200, 224)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 240, 181, 178), Color.fromARGB(255, 171, 200, 224)],
                  ),
          ),
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(1),
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 2,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'SWR',
                  units: '',
                  vehicle: widget.vehicle,
                  value: 'swr',
                  decimalPlaces: 3,
                  bottomRange: 1,
                  topRange: 5,
                  lowSector: 1.3,
                  medSector: 1.7,
                  highSector: 1.0,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.green,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Modulation',
                  units: '%',
                  vehicle: widget.vehicle,
                  value: 'peakmodulation',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 110,
                  lowSector: 40.0,
                  medSector: 65.0,
                  highSector: 5.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Power Out',
                  units: 'Watts',
                  vehicle: widget.vehicle,
                  value: 'poweroutput',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 110,
                  lowSector: 35,
                  medSector: 70,
                  highSector: 5.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Power Ref',
                  units: 'Watts',
                  vehicle: widget.vehicle,
                  value: 'powerreflected',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 20,
                  lowSector: 5,
                  medSector: 5,
                  highSector: 10,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.green,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Heat Temp',
                  units: '°C',
                  vehicle: widget.vehicle,
                  value: 'heatsinktemp',
                  decimalPlaces: 2,
                  bottomRange: 25,
                  topRange: 90,
                  lowSector: 20,
                  medSector: 20,
                  highSector: 25,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.orange,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Fan Speed',
                  units: 'RPM',
                  decimalPlaces: 0,
                  vehicle: widget.vehicle,
                  value: 'fanspeed',
                  bottomRange: 5000,
                  topRange: 9000,
                  lowSector: 2000,
                  medSector: 1000,
                  highSector: 1000.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: NewGradientAppBar(
          gradient:
              const LinearGradient(colors: [Color.fromARGB(255, 173, 83, 78), Color.fromARGB(255, 108, 169, 197)]),
          title: AutoSizeText(
            widget.vehicle.stationName.toString() +
                " " +
                widget.vehicle.frequency.toString() +
                ' ' +
                DateFormat.Md().add_jms().format(DateTime.parse(widget.vehicle.date.toString()).toLocal()).toString(),
            minFontSize: 3,
          ),
        ),
        body: Container(
          // ignore: prefer_const_constructors
          decoration: BoxDecoration(
            color: Colors.white70,
            gradient: _gridRows > 1
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 240, 181, 178), Color.fromARGB(255, 171, 200, 224)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromARGB(255, 240, 181, 178), Color.fromARGB(255, 171, 200, 224)],
                  ),
          ),
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(1),
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            crossAxisCount: 2,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'SWR',
                  units: '',
                  vehicle: widget.vehicle,
                  value: 'swr',
                  decimalPlaces: 3,
                  bottomRange: 1,
                  topRange: 5,
                  lowSector: 1.3,
                  medSector: 1.7,
                  highSector: 1.0,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.green,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Modulation',
                  units: '%',
                  vehicle: widget.vehicle,
                  value: 'peakmodulation',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 110,
                  lowSector: 40.0,
                  medSector: 65.0,
                  highSector: 5.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Power Out',
                  units: 'Watts',
                  vehicle: widget.vehicle,
                  value: 'poweroutput',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 110,
                  lowSector: 35,
                  medSector: 70,
                  highSector: 5.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Power Ref',
                  units: 'Watts',
                  vehicle: widget.vehicle,
                  value: 'powerreflected',
                  decimalPlaces: 3,
                  bottomRange: 0,
                  topRange: 20,
                  lowSector: 5,
                  medSector: 5,
                  highSector: 10,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.green,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Heat Temp',
                  units: '°C',
                  vehicle: widget.vehicle,
                  value: 'heatsinktemp',
                  decimalPlaces: 2,
                  bottomRange: 25,
                  topRange: 90,
                  lowSector: 20,
                  medSector: 20,
                  highSector: 25,
                  lowColor: Colors.lightGreen,
                  medColor: Colors.orange,
                  highColor: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: GaugeWidget(
                  measurement: 'Fan Speed',
                  units: 'RPM',
                  decimalPlaces: 0,
                  vehicle: widget.vehicle,
                  value: 'fanspeed',
                  bottomRange: 5000,
                  topRange: 9000,
                  lowSector: 2000,
                  medSector: 1000,
                  highSector: 1000.0,
                  lowColor: Colors.red,
                  medColor: Colors.lightGreen,
                  highColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
