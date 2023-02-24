import 'package:gpsapp/models/vehiclemodel.dart';

import 'dart:convert';

void lookupVehicle(Vehicle vehicle, String result) async {
  var localVehicle = Vehicle(vehicleName: 'stationName', longitude: '0', latitude: '0');

  localVehicle = Vehicle.fromJson(json.decode(result));
  vehicle.vehicleName = localVehicle.vehicleName;
  vehicle.longitude = localVehicle.longitude;
  vehicle.latitude = localVehicle.latitude;
  vehicle.speed = localVehicle.speed;
  vehicle.time = localVehicle.time;

}
