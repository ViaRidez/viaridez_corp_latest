class RouteModel {
  final int id;
  final String startLocation;
  final String endLocation;
  final double totalDistanceKm;
  final String? estimatedTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final List<PitStop> pitStops;
  final String routeType;
  final bool b2bRoute;
  final bool b2cRoute;

  RouteModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.totalDistanceKm,
    this.estimatedTime,
    required this.createdAt,
    required this.updatedAt,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.pitStops,
    required this.routeType,
    required this.b2bRoute,
    required this.b2cRoute,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    List<PitStop> pitStops = [];
    if (json['pitStops'] != null) {
      pitStops = List<PitStop>.from(
        json['pitStops'].map((x) => PitStop.fromJson(x)),
      );
    }

    return RouteModel(
      id: json['id'],
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      totalDistanceKm: json['totalDistanceKm']?.toDouble() ?? 0.0,
      estimatedTime: json['estimatedTime'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      startLatitude: json['startLatitude']?.toDouble() ?? 0.0,
      startLongitude: json['startLongitude']?.toDouble() ?? 0.0,
      endLatitude: json['endLatitude']?.toDouble() ?? 0.0,
      endLongitude: json['endLongitude']?.toDouble() ?? 0.0,
      pitStops: pitStops,
      routeType: json['routeType'] ?? '',
      b2bRoute: json['b2bRoute'] ?? false,
      b2cRoute: json['b2cRoute'] ?? false,
    );
  }

  static DateTime _parseDateTime(List<dynamic>? dateValues) {
    if (dateValues == null || dateValues.length < 3) {
      return DateTime.now();
    }

    try {
      int year = dateValues[0];
      int month = dateValues[1];
      int day = dateValues[2];

      int hour = dateValues.length > 3 ? dateValues[3] : 0;
      int minute = dateValues.length > 4 ? dateValues[4] : 0;
      int second = dateValues.length > 5 ? dateValues[5] : 0;
      int millisecond = dateValues.length > 6 ? (dateValues[6] ~/ 1000000) : 0;

      return DateTime(year, month, day, hour, minute, second, millisecond);
    } catch (e) {
      //debugprint('Error parsing date: $e');
      return DateTime.now();
    }
  }
}

class PitStop {
  final String name;
  final double latitude;
  final double longitude;

  PitStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory PitStop.fromJson(Map<String, dynamic> json) {
    return PitStop(
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}
