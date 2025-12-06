class JourneyModel {
  final int id;
  final String? driverNotificationTime;
  final String hubLocation;
  final String clientName;
  final String? hubStartTime;
  final String? firstPickupTime;
  final String? firstPickupPoint;
  final List<PitStop> pitStops;
  final double totalDistanceInKm;
  final int totalNumberOfPssenger;
  final String startDestination;
  final String finalDestination;
  final String? destinationReachTime;
  final String? shiftTime;
  final String createdAt;
  final String journeyStartDateTime;
  final String journeyEndTime;
  final String? createdBy;
  final String? journeyDuration;
  final String pocClient;
  final String pocClientNumbre;
  final String pocOperation;
  final String pocOperationNumber;
  final String note;
  final String journeyType;
  final String branchName;
  final List<int> shiftStartTime;
  final List<String> workingDays;
  final String? journeyStartDate;
  final int numberOfPeople;
  final List<String> requestedPassengerIds;
  final String? actionTakenBy;
  final String? statusName;
  final bool b2b;
  final bool b2c;

  JourneyModel({
    required this.id,
    this.driverNotificationTime,
    required this.hubLocation,
    required this.clientName,
    this.hubStartTime,
    this.firstPickupTime,
    this.firstPickupPoint,
    required this.pitStops,
    required this.totalDistanceInKm,
    required this.totalNumberOfPssenger,
    required this.startDestination,
    required this.finalDestination,
    this.destinationReachTime,
    this.shiftTime,
    required this.createdAt,
    required this.journeyStartDateTime,
    required this.journeyEndTime,
    this.createdBy,
    this.journeyDuration,
    required this.pocClient,
    required this.pocClientNumbre,
    required this.pocOperation,
    required this.pocOperationNumber,
    required this.note,
    required this.journeyType,
    required this.branchName,
    required this.shiftStartTime,
    required this.workingDays,
    this.journeyStartDate,
    required this.numberOfPeople,
    required this.requestedPassengerIds,
    this.actionTakenBy,
    this.statusName,
    required this.b2b,
    required this.b2c,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'] ?? 0,
      driverNotificationTime: json['driverNotificationTime']?.toString(),
      hubLocation: json['hubLocation']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      hubStartTime: json['hubStartTime']?.toString(),
      firstPickupTime: json['firstPickupTime']?.toString(),
      firstPickupPoint: json['firstPickupPoint']?.toString(),
      pitStops: (json['pitStops'] as List<dynamic>?)
              ?.map((e) => PitStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalDistanceInKm: (json['totalDistanceInKm'] ?? 0.0).toDouble(),
      totalNumberOfPssenger: json['totalNumberOfPssenger'] ?? 0,
      startDestination: json['startDestination']?.toString() ?? '',
      finalDestination: json['finalDestination']?.toString() ?? '',
      destinationReachTime: json['destinationReachTime']?.toString(),
      shiftTime: json['shiftTime']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      journeyStartDateTime: json['journeyStartDateTime']?.toString() ?? '',
      journeyEndTime: json['journeyEndTime']?.toString() ?? '',
      createdBy: json['createdBy']?.toString(),
      journeyDuration: json['journeyDuration']?.toString(),
      pocClient: json['pocClient']?.toString() ?? '',
      pocClientNumbre: json['pocClientNumbre']?.toString() ?? '',
      pocOperation: json['pocOperation']?.toString() ?? '',
      pocOperationNumber: json['pocOperationNumber']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      journeyType: json['journeyType']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      shiftStartTime: (json['shiftStartTime'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      journeyStartDate: json['journeyStartDate']?.toString(),
      numberOfPeople: json['numberOfPeople'] ?? 0,
      requestedPassengerIds: (json['requestedPassengerIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      actionTakenBy: json['actionTakenBy']?.toString(),
      statusName: json['statusName']?.toString(),
      b2b: json['b2b'] ?? false,
      b2c: json['b2c'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverNotificationTime': driverNotificationTime,
      'hubLocation': hubLocation,
      'clientName': clientName,
      'hubStartTime': hubStartTime,
      'firstPickupTime': firstPickupTime,
      'firstPickupPoint': firstPickupPoint,
      'pitStops': pitStops.map((e) => e.toJson()).toList(),
      'totalDistanceInKm': totalDistanceInKm,
      'totalNumberOfPssenger': totalNumberOfPssenger,
      'startDestination': startDestination,
      'finalDestination': finalDestination,
      'destinationReachTime': destinationReachTime,
      'shiftTime': shiftTime,
      'createdAt': createdAt,
      'journeyStartDateTime': journeyStartDateTime,
      'journeyEndTime': journeyEndTime,
      'createdBy': createdBy,
      'journeyDuration': journeyDuration,
      'pocClient': pocClient,
      'pocClientNumbre': pocClientNumbre,
      'pocOperation': pocOperation,
      'pocOperationNumber': pocOperationNumber,
      'note': note,
      'journeyType': journeyType,
      'branchName': branchName,
      'shiftStartTime': shiftStartTime,
      'workingDays': workingDays,
      'journeyStartDate': journeyStartDate,
      'numberOfPeople': numberOfPeople,
      'requestedPassengerIds': requestedPassengerIds,
      'actionTakenBy': actionTakenBy,
      'statusName': statusName,
      'b2b': b2b,
      'b2c': b2c,
    };
  }

  @override
  String toString() {
    return 'JourneyModel(id: $id, hubLocation: $hubLocation, clientName: $clientName, journeyType: $journeyType)';
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
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'PitStop(name: $name, lat: $latitude, lng: $longitude)';
  }
}
