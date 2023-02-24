class Vehicle {
  String vehicleName;
  double latitude;
  double longitude;
  double speed;
  String time;

  Vehicle({
    required this.vehicleName,
    this.latitude = 0,
    this.longitude = 0,
    this.speed = 0,
    this.time = "0"
  });

  Vehicle.fromJson(Map<String, dynamic> json)
      : vehicleName = json['vehicleName'],
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

  @override
  bool operator ==(Object other) {
    if (other is Vehicle) {
      return vehicleName == other.vehicleName;
    }
    return false;
  }
  
  @override
  int get hashCode => vehicleName.hashCode;
  
  
  
  
  
  

  

}
