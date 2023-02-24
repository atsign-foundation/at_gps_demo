import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Maps imports
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as Vector;
import 'package:latlong2/latlong.dart';

import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'package:gpsapp/models/vehiclemodel.dart';
import 'package:gpsapp/screens/onboarding_screen.dart';

import '../vehicle_lookup.dart';
import '../api_key.dart';

// * Once the onboarding process is completed you will be taken to this screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = '/home';

  @override
  Widget build(BuildContext context) {
    // * Getting the AtClientManager instance to use below
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'atGPS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'atGPS'),
      routes: {
        HomeScreen.id: (_) => const HomeScreen(),
        OnboardingScreen.id: (_) => const OnboardingScreen(),
        //Next.id: (_) => const Next(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Timer? timer;
  final MapController _controller = MapController();
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    String nameSpace = 'atgps_receiver';
    Set<Vehicle> vehicles = {};

    AtClientManager atClientManager = AtClientManager.getInstance();
    String? atSign = atClientManager.atClient.getCurrentAtSign();
    NotificationService notificationService = atClientManager.atClient.notificationService;

    notificationService.subscribe(regex: '@atgps_receiver:{"device":"car', shouldDecrypt: true).listen(
        ((notification) async {
      String? sendingAtsign = notification.from;
      String? json = notification.key;
      json = json.replaceFirst('@atgps_receiver:', '');
      print(json);
      int timeNow = DateTime.now().millisecondsSinceEpoch;
      var decodeJson = jsonDecode(json.toString());
      int timeSent = int.parse(decodeJson['Time']);
      int timeDelay = timeNow - timeSent;
      // if (timeSent > lastTime) {
      //   lastTime = timeSent;
      print('Time Delay: $timeDelay');
      decodeJson['Time'] = '${timeDelay.toString()} ms';

      Vehicle vehicleData = Vehicle(vehicleName: decodeJson['device']);
      vehicleData.latitude = double.parse(decodeJson['latitude']);
      vehicleData.longitude = double.parse(decodeJson['longitude']);
      markers.clear();
      vehicles.add(vehicleData);
      print(vehicles.length);
      for (var vehicle in vehicles) {
        if (vehicleData == vehicle) {
          Marker marker = Marker(
              point: LatLng(vehicleData.latitude, vehicleData.longitude),
              width: 38,
              height: 38,
              builder: (context) => Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      // ignore: prefer_const_constructors
                      Icon(
                        Icons.directions_car_filled,
                        color: Colors.green,
                        size: 40,
                      ),
                      Text(
                        " ${vehicleData.vehicleName}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ],
                  ));
          markers.add(marker);
        } else {
          Marker marker = Marker(
              point: LatLng(vehicle.latitude, vehicle.longitude),
              width: 38,
              height: 38,
              builder: (context) => Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      // ignore: prefer_const_constructors
                      Icon(
                        Icons.directions_car_filled,
                        color: Colors.red,
                        size: 40,
                      ),
                      Text(
                        " ${vehicle.vehicleName}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ],
                  ));
          markers.add(marker);
        }
      }
      print('Markers>>'+markers.length.toString());
      setState(() {});
    }),
        onError: (e) => print('Notification Failed:' + e.toString()),
        onDone: () => print('Notification listener stopped'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NewGradientAppBar(
          gradient:
              const LinearGradient(colors: [Color.fromARGB(255, 78, 173, 80), Color.fromARGB(255, 108, 169, 197)]),
          title: const AutoSizeText(
            'atGPS',
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
        body: SafeArea(
            child: Column(children: [
          Flexible(
              child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
                center: LatLng(0, 0),
                zoom: 10,
                maxZoom: 22,
                interactiveFlags: InteractiveFlag.drag |
                    InteractiveFlag.flingAnimation |
                    InteractiveFlag.pinchMove |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom),
            children: [
              // normally you would see TileLayer which provides raster tiles
              // instead this vector tile layer replaces the standard tile layer
              VectorTileLayer(
                theme: _mapTheme(),
                backgroundTheme: _backgroundTheme(),
                // tileOffset: TileOffset.mapbox, enable with mapbox
                tileProviders: TileProviders(
                    // Name must match name under "sources" in theme
                    {'openmaptiles': _cachingTileProvider(_urlTemplate())}),
              ),
              MarkerLayer(markers: markers),
            ],
          )),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_statusText()])
        ])));
  }

  VectorTileProvider _cachingTileProvider(String urlTemplate) {
    return MemoryCacheVectorTileProvider(
        delegate: NetworkVectorTileProvider(
            urlTemplate: urlTemplate,
            // this is the maximum zoom of the provider, not the
            // maximum of the map. vector tiles are rendered
            // to larger sizes to support higher zoom levels
            maximumZoom: 14),
        maxSizeBytes: 1024 * 1024 * 2);
  }

  Vector.Theme _mapTheme() {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    return Vector.ProvidedThemes.lightTheme();
    // return ThemeReader(logger: const Logger.console())
    //     .read(myCustomStyle());
  }

  _backgroundTheme() {
    return _mapTheme().copyWith(types: {Vector.ThemeLayerType.background, Vector.ThemeLayerType.fill});
  }

  String _urlTemplate() {
    // IMPORTANT: See readme about matching tile provider with theme

    // Stadia Maps source https://docs.stadiamaps.com/vector/
    // ignore: undefined_identifier
    // return 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=$stadiaMapsApiKey';

    // Maptiler source
    return 'https://api.maptiler.com/tiles/v3/{z}/{x}/{y}.pbf?key=$maptilerApiKey';

    // Mapbox source https://docs.mapbox.com/api/maps/vector-tiles/#example-request-retrieve-vector-tiles
    // return 'https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/{z}/{x}/{y}.mvt?access_token=$mapboxApiKey',
  }

  Widget _statusText() => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: StreamBuilder(
          stream: _controller.mapEventStream,
          builder: (context, snapshot) {
            return Text(
                'Zoom: ${_controller.zoom.toStringAsFixed(2)} Center: ${_controller.center.latitude.toStringAsFixed(4)},${_controller.center.longitude.toStringAsFixed(4)}');
          }));
}
