class SoilSensor {
  final String id;
  final String userId;
  final String? plantId;
  final int humidity;
  final double? temperature;
  final String? sensorId;
  final String? location;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SoilSensor({
    required this.id,
    required this.userId,
    this.plantId,
    required this.humidity,
    this.temperature,
    this.sensorId,
    this.location,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SoilSensor.fromJson(Map<String, dynamic> json) {
    return SoilSensor(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      plantId: json['plantId'],
      humidity: json['humidity']?.toInt() ?? 0,
      temperature: json['temperature']?.toDouble(),
      sensorId: json['sensorId'],
      location: json['location'],
      recordedAt: json['recordedAt'] != null
          ? DateTime.parse(json['recordedAt'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'plantId': plantId,
      'humidity': humidity,
      'temperature': temperature,
      'sensorId': sensorId,
      'location': location,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
