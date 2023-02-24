class Vehicle {
  String vehicleName;
  String? latitude;
  String? longitude;
  String? speed;
  String? time;

  Vehicle({
    required this.vehicleName,
    required this.latitude,
    required this.longitude,
    this.speed = '0',
    this.time = '0',
  });

  Vehicle.fromJson(Map<String, dynamic> json)
      : vehicleName = json['vechileName'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        speed = json['speed'],
        time = json['time'];

  Vehicle.fromJsonLong(Map<String, dynamic> json)
      : vehicleName = json['"vehicleName"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        latitude = json['"latitude"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        longitude = json['"longitude"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        speed = json['"speed"'].toString().replaceAll(RegExp('(^")|("\$)'), ''),
        time = json['"time"'].toString().replaceAll(RegExp('(^")|("\$)'), '');

  Map<String, dynamic> toJson() => {
        'vehicleName': vehicleName,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'time': time
      };

  Map<String, dynamic> toJsonLong() => {
        '"vehicleName"': '"$vehicleName"',
        '"latitude"': '"$latitude"',
        '"longitude"': '"$longitude"',
        '"speed"': '"$speed"',
        '"time"': '"$time"'
      };
}
