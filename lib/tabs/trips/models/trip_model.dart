class PitStop {
  final String? name;
  final double? latitude;
  final double? longitude;

  PitStop({
    this.name,
    this.latitude,
    this.longitude,
  });

  factory PitStop.fromJson(Map<String, dynamic> json) {
    return PitStop(
      name: json['name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
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

class TripModel {
  final int id;
  final String? hubLocation;
  final String? firstSource;
  final String? tripType;
  final String? startDestination;
  final String? pocClient;
  final String? pocClientNumber;
  final String? pocOperaion;
  final String? pocOperationNumber;
  final List<PitStop>? pitStops;
  final String? finalDestination;
  final List<int>? startTime;
  final List<int>? endTime;
  final List<int>? createdAt;
  final String? shuttle;
  final int? driverIdd;
  final String? driverFirstName;
  final String? driverLastName;
  final int? totalNumberOfPssenger;
  final bool? tripAccepted;
  final String? reasonForReject;
  final String? tripStatus;
  final double? totalDistanceInKm;
  final List<int>? shiftStartTime;
  final List<int>? pickupTime; // Changed from String? to List<int>?
  final String? branchName;
  final String? notes;
  final List<String>? workingDays;
  final int? routeId;
  final String? vehicleRegistrationNumber;
  final String? vehicleOwnId;
  final int? seater;
  final String? brand;
  final String? model;
  final String? driverPhoneNumber;
  final List<dynamic>? driverRatings;
  final double? price;

  TripModel({
    required this.id,
    this.hubLocation,
    this.firstSource,
    this.tripType,
    this.startDestination,
    this.pocClient,
    this.pocClientNumber,
    this.pocOperaion,
    this.pocOperationNumber,
    this.pitStops,
    this.finalDestination,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.shuttle,
    this.driverIdd,
    this.driverFirstName,
    this.driverLastName,
    this.totalNumberOfPssenger,
    this.tripAccepted,
    this.reasonForReject,
    this.tripStatus,
    this.totalDistanceInKm,
    this.shiftStartTime,
    this.pickupTime,
    this.branchName,
    this.notes,
    this.workingDays,
    this.routeId,
    this.vehicleRegistrationNumber,
    this.vehicleOwnId,
    this.seater,
    this.brand,
    this.model,
    this.driverPhoneNumber,
    this.driverRatings,
    this.price,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      hubLocation: json['hubLocation'],
      firstSource: json['firstSource'],
      tripType: json['tripType'],
      startDestination: json['startDestination'],
      pocClient: json['pocClient'],
      pocClientNumber: json['pocClientNumber'],
      pocOperaion: json['pocOperaion'],
      pocOperationNumber: json['pocOperationNumber'],
      pitStops: json['pitStops'] != null
          ? (json['pitStops'] as List).map((e) => PitStop.fromJson(e)).toList()
          : null,
      finalDestination: json['finalDestination'],
      startTime: _parseIntList(json['startTime']),
      endTime: _parseIntList(json['endTime']),
      createdAt: _parseIntList(json['createdAt']),
      shuttle: json['shuttle'],
      driverIdd: json['driverIdd'],
      driverFirstName: json['driverFirstName'],
      driverLastName: json['driverLastName'],
      totalNumberOfPssenger: json['totalNumberOfPssenger'],
      tripAccepted: json['tripAccepted'],
      reasonForReject: json['reasonForReject'],
      tripStatus: json['tripStatus'],
      totalDistanceInKm: json['totalDistanceInKm']?.toDouble(),
      shiftStartTime: _parseIntList(json['shiftStartTime']),
      pickupTime: _parseIntList(json['pickupTime']),
      branchName: json['branchName'],
      notes: json['notes'],
      workingDays: _parseStringList(json['workingDays']),
      routeId: json['routeId'],
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
      vehicleOwnId: json['vehicleOwnId'],
      seater: json['seater'],
      brand: json['brand'],
      model: json['model'],
      driverPhoneNumber: json['driverPhoneNumber'],
      driverRatings: json['driverRatings'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hubLocation': hubLocation,
      'firstSource': firstSource,
      'tripType': tripType,
      'startDestination': startDestination,
      'pocClient': pocClient,
      'pocClientNumber': pocClientNumber,
      'pocOperaion': pocOperaion,
      'pocOperationNumber': pocOperationNumber,
      'pitStops': pitStops?.map((e) => e.toJson()).toList(),
      'finalDestination': finalDestination,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt,
      'shuttle': shuttle,
      'driverIdd': driverIdd,
      'driverFirstName': driverFirstName,
      'driverLastName': driverLastName,
      'totalNumberOfPssenger': totalNumberOfPssenger,
      'tripAccepted': tripAccepted,
      'reasonForReject': reasonForReject,
      'tripStatus': tripStatus,
      'totalDistanceInKm': totalDistanceInKm,
      'shiftStartTime': shiftStartTime,
      'pickupTime': pickupTime,
      'branchName': branchName,
      'notes': notes,
      'workingDays': workingDays,
      'routeId': routeId,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'vehicleOwnId': vehicleOwnId,
      'seater': seater,
      'brand': brand,
      'model': model,
      'driverPhoneNumber': driverPhoneNumber,
      'driverRatings': driverRatings,
      'price': price,
    };
  }

  // Helper methods for JSON parsing
  static List<int>? _parseIntList(dynamic value) {
    if (value == null) return null;
    try {
      if (value is List) {
        return value
            .map((e) => e is int ? e : int.parse(e.toString()))
            .toList();
      }
      return null;
    } catch (e) {
      // print('Error parsing int list: $e');
      return null;
    }
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    try {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    } catch (e) {
      // print('Error parsing string list: $e');
      return null;
    }
  }

  // Helper methods for formatting
  String get formattedStartTime {
    if (startTime == null || startTime!.length < 5) return 'N/A';
    return '${startTime![3].toString().padLeft(2, '0')}:${startTime![4].toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    if (endTime == null || endTime!.length < 5) return 'N/A';
    return '${endTime![3].toString().padLeft(2, '0')}:${endTime![4].toString().padLeft(2, '0')}';
  }

  String get formattedPickupTime {
    if (pickupTime == null || pickupTime!.length < 2) return 'N/A';
    return '${pickupTime![0].toString().padLeft(2, '0')}:${pickupTime![1].toString().padLeft(2, '0')}';
  }

  String get formattedCreatedDate {
    if (createdAt == null || createdAt!.length < 3) return 'N/A';
    return '${createdAt![2]}/${createdAt![1]}/${createdAt![0]}';
  }

  String get formattedStartDate {
    if (startTime == null || startTime!.length < 3) return 'N/A';
    return '${startTime![2].toString().padLeft(2, '0')}/${startTime![1].toString().padLeft(2, '0')}/${startTime![0]}';
  }

  String get formattedEndDate {
    if (endTime == null || endTime!.length < 3) return 'N/A';
    return '${endTime![2].toString().padLeft(2, '0')}/${endTime![1].toString().padLeft(2, '0')}/${endTime![0]}';
  }

  String get driverFullName {
    if (driverFirstName == null && driverLastName == null) return 'N/A';
    return '${driverFirstName ?? ''} ${driverLastName ?? ''}'.trim();
  }

  String get pitStopsCount {
    return pitStops?.length.toString() ?? '0';
  }
}

enum TripStatus {
  unallocated,
  completed,
  ongoing,
  pending,
  cancel;

  String get displayName {
    switch (this) {
      case TripStatus.unallocated:
        return 'Unallocated';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.ongoing:
        return 'Ongoing';
      case TripStatus.pending:
        return 'Pending';
      case TripStatus.cancel:
        return 'Cancelled';
    }
  }

  static TripStatus? fromString(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase()) {
      case 'unallocated':
        return TripStatus.unallocated;
      case 'completed':
        return TripStatus.completed;
      case 'ongoing':
        return TripStatus.ongoing;
      case 'pending':
        return TripStatus.pending;
      case 'cancel':
      case 'cancelled':
        return TripStatus.cancel;
      default:
        return null;
    }
  }
}
