// ignore_for_file: file_names

import 'package:gpsapp/models/vehiclemodel.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter/material.dart';

class GaugeWidget extends StatefulWidget {
  final String measurement;
  final String value;
  final int decimalPlaces;
  final String units;
  final double bottomRange;
  final double topRange;
  final Color lowColor;
  final Color medColor;
  final Color highColor;
  final double lowSector;
  final double medSector;
  final double highSector;
  final Vehicle vehicle;
  final double lastvalue;

  const GaugeWidget(
      {Key? key,
      required this.measurement,
      required this.units,
      required this.vehicle,
      required this.value,
      this.decimalPlaces = 2,
      this.lastvalue = 0,
      this.bottomRange = 0,
      this.topRange = 100,
      this.highColor = Colors.red,
      this.medColor = Colors.orange,
      this.lowColor = Colors.green,
      this.highSector = 40.0,
      this.medSector = 40.0,
      this.lowSector = 20.0})
      : super(key: key);

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double read = getValue(widget.value);
    double reading = getMeter(widget.value);
    var step = (widget.topRange - widget.bottomRange) / 1000;
    return TimerBuilder.periodic(const Duration(milliseconds: 10), builder: (context) {
      read = getValue(widget.value);
      if (reading - step > read) {
        reading = reading - step;
      } else if (reading + step < read) {
        reading = reading + step;
      } else {
        reading = read;
      }
      setMeter(widget.value, reading);

      return Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        PrettyGauge(
          gaugeSize: 170,
          currentValueDecimalPlaces: widget.decimalPlaces,
          minValue: widget.bottomRange,
          maxValue: widget.topRange,
          segments: [
            GaugeSegment('Low', widget.lowSector, widget.lowColor),
            GaugeSegment('Medium', widget.medSector, widget.medColor),
            GaugeSegment('High', widget.highSector, widget.highColor),
          ],
          currentValue: reading,
          displayWidget: Text(widget.measurement, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.units,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ))
      ]);

      // return  Text("${DateTime.now()}");
    });
  }

  double getValue(String value) {
    String? result;
    switch (value) {
      case 'fanspeed':
        result = widget.vehicle.fanspeed;
        break;
      case 'heatsinktemp':
        result = widget.vehicle.heatsinktemp;
        break;
      case 'peakmodulation':
        result = widget.vehicle.peakmodulation;
        break;
      case 'poweroutput':
        result = widget.vehicle.poweroutput;
        break;
      case 'powerreflected':
        result = widget.vehicle.powerreflected;
        break;
      case 'swr':
        result = widget.vehicle.swr;
        break;
      default:
        result = "0.0";
        break;
    }
    return (double.parse(result!));
  }

  double getMeter(String value) {
    String? result;
    switch (value) {
      case 'fanspeed':
        result = widget.vehicle.meterFanspeed;
        break;
      case 'heatsinktemp':
        result = widget.vehicle.meterHeatsinktemp;
        break;
      case 'peakmodulation':
        result = widget.vehicle.meterPeakmodulation;
        break;
      case 'poweroutput':
        result = widget.vehicle.meterPoweroutput;
        break;
      case 'powerreflected':
        result = widget.vehicle.meterPowerreflected;
        break;
      case 'swr':
        result = widget.vehicle.meterSwr;
        break;
      default:
        result = "0.0";
        break;
    }
    return (double.parse(result!));
  }

  setMeter(String value, double reading) {
    switch (value) {
      case 'fanspeed':
        widget.vehicle.meterFanspeed = reading.toString();
        break;
      case 'heatsinktemp':
        widget.vehicle.meterHeatsinktemp = reading.toString();
        {}
        break;
      case 'peakmodulation':
        widget.vehicle.meterPeakmodulation = reading.toString();
        {}
        break;
      case 'poweroutput':
        widget.vehicle.meterPoweroutput = reading.toString();
        {}
        break;
      case 'powerreflected':
        widget.vehicle.meterPowerreflected = reading.toString();
        {}
        break;
      case 'swr':
        widget.vehicle.meterSwr = reading.toString();
        {}
        break;
      default:
        break;
    }
  }
}
