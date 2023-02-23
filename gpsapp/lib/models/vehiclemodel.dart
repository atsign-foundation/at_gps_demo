class Vehicle {
  String stationName;
  String? frequency;
  String? ip;
  String? fanspeed;
  String? heatsinktemp;
  String? peakmodulation;
  String? poweroutput;
  String? powerreflected;
  String? swr;
  String? date;
  String? meterFanspeed;
  String? meterHeatsinktemp;
  String? meterPeakmodulation;
  String? meterPoweroutput;
  String? meterPowerreflected;
  String? meterSwr;

  Vehicle(
      {required this.stationName,
      required this.frequency,
      required this.ip,
      this.fanspeed = '0',
      this.heatsinktemp = '0',
      this.peakmodulation = '0',
      this.poweroutput = '0',
      this.powerreflected = '0',
      this.date = '1970-01-01 00:00:00.000000Z',
      this.swr = '0',
      this.meterFanspeed = '5000',
      this.meterHeatsinktemp = '0',
      this.meterPeakmodulation = '0',
      this.meterPoweroutput = '0',
      this.meterPowerreflected = '0',
      this.meterSwr = '0',
      });
  

  Vehicle.fromJson(Map<String, dynamic> json)
      : stationName = json['stationName'],
        frequency = json['frequency'],
        ip = json['ip'],
        fanspeed = json['fanspeed'],
        heatsinktemp = json['heatsinktemp'],
        peakmodulation = json['peakmodulation'],
        poweroutput = json['poweroutput'],
        powerreflected = json['powerreflected'],
        date = json['date'],
        swr = json['swr'];

  Vehicle.fromJsonLong(Map<String, dynamic> json)
      : stationName = json['"stationName"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        frequency = json['"frequency"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        ip = json['"ip"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        fanspeed = json['"fanspeed"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        heatsinktemp = json['"heatsinktemp"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        peakmodulation = json['"peakmodulation"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        poweroutput = json['"powerout"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        powerreflected = json['"powerreflected"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        date = json['"date"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        swr = json['"swr"'].toString().replaceAll(RegExp('(^")|("\$)'), '');

  Map<String, dynamic> toJson() => {
        'stationName': stationName,
        'frequency': frequency,
        'ip': ip,
        'fanspeed': fanspeed,
        'heatsinktemp': heatsinktemp,
        'peakmodulation': peakmodulation,
        'poweroutput': poweroutput,
        'powerreflected': powerreflected,
        'date': date,
        'swr': swr,
      };

  Map<String, dynamic> toJsonLong() => {
        '"stationName"':'"$stationName"',
        '"frequency"': '"$frequency"',
        '"ip"': '"$ip"',
        '"fanspeed"': '"$fanspeed"',
        '"heatsinktemp"': '"$heatsinktemp"',
        '"peakmodulation"': '"$peakmodulation"',
        '"poweroutput"': '"$poweroutput"',
        '"powerreflected"': '"$powerreflected"',
        '"date"': '"$date"',
        '"swr"': '"$swr"',
      };
}
