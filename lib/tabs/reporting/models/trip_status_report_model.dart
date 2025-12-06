class TripStatusReportModel {
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

  TripStatusReportModel({
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
  });

  factory TripStatusReportModel.fromJson(Map<String, dynamic> json) {
    return TripStatusReportModel(
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
    };
  }

  // Helper method to get DateTime from startTime list
  DateTime? get startDateTime {
    if (startTime.length >= 5) {
      return DateTime(
          startTime[0], startTime[1], startTime[2], startTime[3], startTime[4]);
    } else if (startTime.length >= 3) {
      return DateTime(startTime[0], startTime[1], startTime[2]);
    }
    return null;
  }

  // Helper method to get DateTime from endTime list
  DateTime? get endDateTime {
    if (endTime.length >= 5) {
      return DateTime(
          endTime[0], endTime[1], endTime[2], endTime[3], endTime[4]);
    } else if (endTime.length >= 3) {
      return DateTime(endTime[0], endTime[1], endTime[2]);
    }
    return null;
  }

  // Helper method to get formatted duration
  String get formattedDuration {
    final start = startDateTime;
    final end = endDateTime;
    if (start != null && end != null) {
      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    }
    return 'N/A';
  }

  // Helper method to check if trip is today
  bool get isToday {
    final start = startDateTime;
    if (start != null) {
      final now = DateTime.now();
      return start.year == now.year &&
          start.month == now.month &&
          start.day == now.day;
    }
    return false;
  }
}
