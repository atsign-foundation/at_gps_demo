import 'package:gpsapp/models/vehiclemodel.dart';

import 'dart:convert';

void lookupTransmitter(Vehicle transmitter, String result) async {
  var localtransmitter = Vehicle(stationName: 'stationName', frequency: 'frequency', ip: 'ip');

    localtransmitter = Vehicle.fromJson(json.decode(result));
    //print('RadioJSON' + transmitter.toString());
    transmitter.stationName = localtransmitter.stationName;
    transmitter.frequency = localtransmitter.frequency;
    transmitter.ip = localtransmitter.ip;
    transmitter.fanspeed = localtransmitter.fanspeed;
    transmitter.heatsinktemp = localtransmitter.heatsinktemp;
    transmitter.peakmodulation = localtransmitter.peakmodulation;
    transmitter.poweroutput = localtransmitter.poweroutput;
    transmitter.powerreflected = localtransmitter.powerreflected;
    transmitter.date = localtransmitter.date;
    transmitter.swr = localtransmitter.swr;
    //print(transmitter.fanspeed);
    //return transmitter;
}
