class Vehicle {
  String vehicleName;
  double? latitude;
  double? longitude;
  double? speed;
  String? time;

  Vehicle({
    required this.vehicleName,
    this.latitude,
    this.longitude,
    this.speed,
    this.time
  });

  Vehicle.fromJson(Map<String, dynamic> json)
      : vehicleName = json['vechileName'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        speed = json['speed'],
        time = json['time'];



  Map<String, dynamic> toJson() => {
        'vehicleName': vehicleName,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'time': time
      };


}
