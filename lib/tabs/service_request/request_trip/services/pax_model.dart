class PaxModel {
  final int id;
  final String firstname;
  final String lastname;
  final String phonenumber;
  final String email;
  final DateTime? startDateTime;
  final String? hubStartTime;
  final List<int>? pickupTime;
  final String clientName;
  final String shiftTime;
  final String boardingPlace;
  final String routeFrom;
  final String routeTo;
  final String? fromLocation;
  final String? toLocation;
  final String? startTime;
  final String? endTime;
  final String? tripType;
  final String? actionTakenByForAttendance;
  final String? commentsIfAbsent;
  final String? passengerType;
  final bool presentForTheTrip;

  PaxModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phonenumber,
    required this.email,
    this.startDateTime,
    this.hubStartTime,
    this.pickupTime,
    required this.clientName,
    required this.shiftTime,
    required this.boardingPlace,
    required this.routeFrom,
    required this.routeTo,
    this.fromLocation,
    this.toLocation,
    this.startTime,
    this.endTime,
    this.tripType,
    this.actionTakenByForAttendance,
    this.commentsIfAbsent,
    this.passengerType,
    required this.presentForTheTrip,
  });

  factory PaxModel.fromJson(Map<String, dynamic> json) {
    return PaxModel(
      id: json['id'] ?? 0,
      firstname: _parseStringField(json['firstname']) ?? '',
      lastname: _parseStringField(json['lastname']) ?? '',
      phonenumber: _parseStringField(json['phonenumber']) ?? '',
      email: _parseStringField(json['email']) ?? '',
      startDateTime: json['startDateTime'] != null
          ? DateTime.tryParse(json['startDateTime'].toString())
          : null,
      hubStartTime: _parseStringField(json['hubStartTime']),
      pickupTime: json['pickupTime'] != null
          ? List<int>.from(json['pickupTime'])
          : null,
      clientName: _parseStringField(json['clientName']) ?? '',
      shiftTime: _parseStringField(json['shiftTime']) ?? '',
      boardingPlace: _parseStringField(json['boardingPlace']) ?? '',
      routeFrom: _parseStringField(json['routeFrom']) ?? '',
      routeTo: _parseStringField(json['routeTo']) ?? '',
      fromLocation: _parseStringField(json['fromLocation']),
      toLocation: _parseStringField(json['toLocation']),
      startTime: _parseStringField(json['startTime']),
      endTime: _parseStringField(json['endTime']),
      tripType: _parseStringField(json['tripType']),
      actionTakenByForAttendance:
          _parseStringField(json['actionTakenByForAttendance']),
      commentsIfAbsent: _parseStringField(json['commentsIfAbsent']),
      passengerType: _parseStringField(json['passengerType']),
      presentForTheTrip: json['presentForTheTrip'] ?? false,
    );
  }

  // Helper method to safely parse string fields that might come as arrays
  static String? _parseStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'phonenumber': phonenumber,
      'email': email,
      'startDateTime': startDateTime?.toIso8601String(),
      'hubStartTime': hubStartTime,
      'pickupTime': pickupTime,
      'clientName': clientName,
      'shiftTime': shiftTime,
      'boardingPlace': boardingPlace,
      'routeFrom': routeFrom,
      'routeTo': routeTo,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'startTime': startTime,
      'endTime': endTime,
      'tripType': tripType,
      'actionTakenByForAttendance': actionTakenByForAttendance,
      'commentsIfAbsent': commentsIfAbsent,
      'passengerType': passengerType,
      'presentForTheTrip': presentForTheTrip,
    };
  }

  // Convenience getters
  String get fullName => '$firstname $lastname';

  String get formattedPickupTime {
    if (pickupTime != null && pickupTime!.length >= 2) {
      final hour = pickupTime![0];
      final minute = pickupTime![1];
      final formattedHour = hour.toString().padLeft(2, '0');
      final formattedMinute = minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute';
    }
    return 'N/A';
  }

  String get attendanceStatus {
    if (presentForTheTrip) {
      return 'Present';
    } else {
      return 'Absent';
    }
  }

  String get routeDescription => '$routeFrom → $routeTo';

  @override
  String toString() {
    return 'PaxModel(id: $id, name: $fullName, client: $clientName, route: $routeDescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaxModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Create a copy with updated fields
  PaxModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? phonenumber,
    String? email,
    DateTime? startDateTime,
    String? hubStartTime,
    List<int>? pickupTime,
    String? clientName,
    String? shiftTime,
    String? boardingPlace,
    String? routeFrom,
    String? routeTo,
    String? fromLocation,
    String? toLocation,
    String? startTime,
    String? endTime,
    String? tripType,
    String? actionTakenByForAttendance,
    String? commentsIfAbsent,
    String? passengerType,
    bool? presentForTheTrip,
  }) {
    return PaxModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phonenumber: phonenumber ?? this.phonenumber,
      email: email ?? this.email,
      startDateTime: startDateTime ?? this.startDateTime,
      hubStartTime: hubStartTime ?? this.hubStartTime,
      pickupTime: pickupTime ?? this.pickupTime,
      clientName: clientName ?? this.clientName,
      shiftTime: shiftTime ?? this.shiftTime,
      boardingPlace: boardingPlace ?? this.boardingPlace,
      routeFrom: routeFrom ?? this.routeFrom,
      routeTo: routeTo ?? this.routeTo,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tripType: tripType ?? this.tripType,
      actionTakenByForAttendance:
          actionTakenByForAttendance ?? this.actionTakenByForAttendance,
      commentsIfAbsent: commentsIfAbsent ?? this.commentsIfAbsent,
      passengerType: passengerType ?? this.passengerType,
      presentForTheTrip: presentForTheTrip ?? this.presentForTheTrip,
    );
  }
}
