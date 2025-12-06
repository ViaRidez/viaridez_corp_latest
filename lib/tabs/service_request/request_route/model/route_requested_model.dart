class RouteRequestedModel {
  final int id;
  final String startLocation;
  final String endLocation;
  final double totalDistanceKm;
  final String? estimatedTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? routeFor;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final List<PitStop> pitStops;
  final String routeType;
  final String statusName;
  final List<dynamic> shuttleAssignments;
  final String requestedBy;
  final String actionTakenBy;
  final String clientName;
  final bool b2bRoute;
  final bool b2cRoute;
  final bool shuttleServiceRoute;

  RouteRequestedModel({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.totalDistanceKm,
    this.estimatedTime,
    required this.createdAt,
    required this.updatedAt,
    this.routeFor,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.pitStops,
    required this.routeType,
    required this.statusName,
    required this.shuttleAssignments,
    required this.requestedBy,
    required this.actionTakenBy,
    required this.clientName,
    required this.b2bRoute,
    required this.b2cRoute,
    required this.shuttleServiceRoute,
  });

  factory RouteRequestedModel.fromJson(Map<String, dynamic> json) {
    List<PitStop> pitStops = [];
    if (json['pitStops'] != null) {
      pitStops = List<PitStop>.from(
        json['pitStops'].map((x) => PitStop.fromJson(x)),
      );
    }

    return RouteRequestedModel(
      id: json['id'] ?? 0,
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      totalDistanceKm: json['totalDistanceKm']?.toDouble() ?? 0.0,
      estimatedTime: json['estimatedTime'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      routeFor: json['routeFor'],
      startLatitude: json['startLatitude']?.toDouble() ?? 0.0,
      startLongitude: json['startLongitude']?.toDouble() ?? 0.0,
      endLatitude: json['endLatitude']?.toDouble() ?? 0.0,
      endLongitude: json['endLongitude']?.toDouble() ?? 0.0,
      pitStops: pitStops,
      routeType: json['routeType'] ?? '',
      statusName: json['statusName'] ?? '',
      shuttleAssignments: json['shuttleAssignments'] ?? [],
      requestedBy: json['requestedBy'] ?? '',
      actionTakenBy: json['actionTakenBy'] ?? '',
      clientName: json['clientName'] ?? '',
      b2bRoute: json['b2bRoute'] ?? false,
      b2cRoute: json['b2cRoute'] ?? false,
      shuttleServiceRoute: json['shuttleServiceRoute'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic dateValues) {
    if (dateValues == null) {
      return DateTime.now();
    }

    // Handle if it's already a DateTime object
    if (dateValues is DateTime) {
      return dateValues;
    }

    // Handle if it's a list of integers (as shown in the API response)
    if (dateValues is List && dateValues.length >= 3) {
      try {
        int year = dateValues[0];
        int month = dateValues[1];
        int day = dateValues[2];

        int hour = dateValues.length > 3 ? dateValues[3] : 0;
        int minute = dateValues.length > 4 ? dateValues[4] : 0;
        int second = dateValues.length > 5 ? dateValues[5] : 0;
        int microsecond = dateValues.length > 6 ? dateValues[6] : 0;

        return DateTime(year, month, day, hour, minute, second, microsecond);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Handle if it's a string
    if (dateValues is String) {
      try {
        return DateTime.parse(dateValues);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'totalDistanceKm': totalDistanceKm,
      'estimatedTime': estimatedTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'routeFor': routeFor,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'pitStops': pitStops.map((x) => x.toJson()).toList(),
      'routeType': routeType,
      'statusName': statusName,
      'shuttleAssignments': shuttleAssignments,
      'requestedBy': requestedBy,
      'actionTakenBy': actionTakenBy,
      'clientName': clientName,
      'b2bRoute': b2bRoute,
      'b2cRoute': b2cRoute,
      'shuttleServiceRoute': shuttleServiceRoute,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

enum RouteStatus {
  requested('Requested'),
  accepted('Accepted'),
  rejected('Rejected');

  const RouteStatus(this.value);
  final String value;

  static RouteStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return RouteStatus.requested;
      case 'accepted':
        return RouteStatus.accepted;
      case 'rejected':
        return RouteStatus.rejected;
      default:
        return RouteStatus.requested;
    }
  }
}
