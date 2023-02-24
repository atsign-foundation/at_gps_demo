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
  HomeScreen({Key? key}) : super(key: key);
  static const String id = '/home';

  final transmitter = Vehicle(vehicleName: 'car1', latitude: '42', longitude: '-83');

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
      home: MyHomePage(title: 'atGPS', vehicle: transmitter),
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
  final MapController _controller = MapController();
    double lat1 = 42;
  double long1 = -83;

  double lat2 = 42;
  double long2 = -83;

  double lat3 = 42;
  double long3 = -83;

  double lat4 = 42;
  double long4 = -83;

  double lat5 = 42;
  double long5 = -83;

  double lat6 = 42;
  double long6 = -83;

  String car = '';
  String car1 = '';
  String car2 = '';
  String car3 = '';
  String car4 = '';
  String car5 = '';
  String car6 = '';

  @override
  void initState() {
    super.initState();
    String nameSpace = 'atgps_receiver';
    if (kIsWeb) {
      connectWs();
    } else {
      AtClientManager atClientManager = AtClientManager.getInstance();
      String? atSign = atClientManager.atClient.getCurrentAtSign();
      NotificationService notificationService = atClientManager.atClient.notificationService;

      notificationService
          .subscribe(regex: '@atgps_receiver:{"device":"car', shouldDecrypt: true)
          .listen(((notification) async {
        String? sendingAtsign = notification.from;
        String? json = notification.key;
        json = json.replaceFirst('@atgps_receiver:', '');
        print(json);
        if (notification.from == '@$nameSpace') {
          print(json);
          lookupVehicle(widget.vehicle, json);
          setState(() {});
        }
      }));
    }
  }

  void connectWs() {
    var channel = WebSocketChannel.connect(Uri.parse('wss://ws.kryzradio.org'));
    channel.stream.listen((message) {
      var json = message;
      lookupVehicle(widget.vehicle, json);
      setState(() {});
    },
        // reconnnect if the WS gets disconnected (yay!)
        onDone: connectWs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('atGPS'),
        ),
        body: SafeArea(
            child: Column(children: [
          Flexible(
              child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
                center: LatLng(lat1, long1),
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
              MarkerLayer(markers: [
                Marker(
                    point: LatLng(lat1, long1),
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
                              " " + car1,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
                Marker(
                    point: LatLng(lat2, long2),
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
                              " " + car2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
                Marker(
                    point: LatLng(lat3, long3),
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
                              " " + car3,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
                Marker(
                    point: LatLng(lat4, long4),
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
                              " " + car4,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
                Marker(
                    point: LatLng(lat5, long5),
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
                              " " + car5,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
                Marker(
                    point: LatLng(lat6, long6),
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
                              " " + car6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        )),
              ]),
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
