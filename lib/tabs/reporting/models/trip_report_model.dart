class TripReportModel {
  final int id;
  final String? tripId;
  final String clientName;
  final String tripStatus;
  final List<int> startTime;
  final List<int> endTime;
  final String driverName;
  final String vehicleNumber;
  final int totalPassengers;
  final int presentPassengers;
  final int noShowPassengers;
  final String startLocation;
  final double startLat;
  final double startLong;
  final String endLocation;
  final double endLat;
  final double endLong;

  TripReportModel({
    required this.id,
    this.tripId,
    required this.clientName,
    required this.tripStatus,
    required this.startTime,
    required this.endTime,
    required this.driverName,
    required this.vehicleNumber,
    required this.totalPassengers,
    required this.presentPassengers,
    required this.noShowPassengers,
    required this.startLocation,
    required this.startLat,
    required this.startLong,
    required this.endLocation,
    required this.endLat,
    required this.endLong,
  });

  factory TripReportModel.fromJson(Map<String, dynamic> json) {
    return TripReportModel(
      id: json['id'] ?? 0,
      tripId: json['tripId'],
      clientName: json['clientName'] ?? '',
      tripStatus: json['tripStatus'] ?? '',
      startTime: List<int>.from(json['startTime'] ?? []),
      endTime: List<int>.from(json['endTime'] ?? []),
      driverName: json['driverName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      totalPassengers: json['totalPassengers'] ?? 0,
      presentPassengers: json['presentPassengers'] ?? 0,
      noShowPassengers: json['noShowPassengers'] ?? 0,
      startLocation: json['startLocation'] ?? '',
      startLat: (json['startLat'] ?? 0.0).toDouble(),
      startLong: (json['startLong'] ?? 0.0).toDouble(),
      endLocation: json['endLocation'] ?? '',
      endLat: (json['endLat'] ?? 0.0).toDouble(),
      endLong: (json['endLong'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'clientName': clientName,
      'tripStatus': tripStatus,
      'startTime': startTime,
      'endTime': endTime,
      'driverName': driverName,
      'vehicleNumber': vehicleNumber,
      'totalPassengers': totalPassengers,
      'presentPassengers': presentPassengers,
      'noShowPassengers': noShowPassengers,
      'startLocation': startLocation,
      'startLat': startLat,
      'startLong': startLong,
      'endLocation': endLocation,
      'endLat': endLat,
      'endLong': endLong,
    };
  }

  // Helper method to get DateTime from startTime list
  DateTime? get startDateTime {
    if (startTime.length >= 5) {
      return DateTime(
          startTime[0], startTime[1], startTime[2], startTime[3], startTime[4]);
    }
    return null;
  }

  // Helper method to get DateTime from endTime list
  DateTime? get endDateTime {
    if (endTime.length >= 5) {
      return DateTime(
          endTime[0], endTime[1], endTime[2], endTime[3], endTime[4]);
    }
    return null;
  }
}
