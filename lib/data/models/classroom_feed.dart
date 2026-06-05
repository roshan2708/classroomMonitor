class ClassroomFeed {
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final int occupancy; // 0 = Empty, 1 = Occupied
  final DateTime createdAt;

  ClassroomFeed({
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.occupancy,
    required this.createdAt,
  });

  factory ClassroomFeed.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? defaultValue;
    }

    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return ClassroomFeed(
      temperature: parseDouble(json['field1'], 0.0),
      humidity: parseDouble(json['field2'], 0.0),
      lightIntensity: parseDouble(json['field3'], 0.0),
      occupancy: parseInt(json['field4'], 0),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field1': temperature.toString(),
      'field2': humidity.toString(),
      'field3': lightIntensity.toString(),
      'field4': occupancy.toString(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  // Getters for status text
  String get tempStatus => temperature > 35.0 ? 'Warning' : 'Normal';
  String get humidityStatus => humidity > 70.0 ? 'High' : 'Normal';
  
  String get lightStatus {
    if (lightIntensity > 600) return 'Bright';
    if (lightIntensity > 300) return 'Moderate';
    return 'Dark';
  }

  bool get isOccupied => occupancy == 1;

  ClassroomFeed copyWith({
    double? temperature,
    double? humidity,
    double? lightIntensity,
    int? occupancy,
    DateTime? createdAt,
  }) {
    return ClassroomFeed(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      occupancy: occupancy ?? this.occupancy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
