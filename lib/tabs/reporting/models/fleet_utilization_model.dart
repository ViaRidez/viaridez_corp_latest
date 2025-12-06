class FleetUtilizationModel {
  final int vehicleId;
  final String registrationNumber;
  final String brand;
  final String model;
  final String status;
  final int totalTrips;
  final double totalDistance;
  final double avgDistancePerTrip;
  final int daysInWorkshop;
  final List<int>? lastUsedDate;
  final bool enabled;
  final bool assigned;
  final bool inWorkshop;

  FleetUtilizationModel({
    required this.vehicleId,
    required this.registrationNumber,
    required this.brand,
    required this.model,
    required this.status,
    required this.totalTrips,
    required this.totalDistance,
    required this.avgDistancePerTrip,
    required this.daysInWorkshop,
    this.lastUsedDate,
    required this.enabled,
    required this.assigned,
    required this.inWorkshop,
  });

  factory FleetUtilizationModel.fromJson(Map<String, dynamic> json) {
    List<int>? lastUsedDate;
    if (json['lastUsedDate'] is List) {
      lastUsedDate = List<int>.from(json['lastUsedDate']);
    } else if (json['lastUsedDate'] is String) {
      // Optionally parse string date if needed
      lastUsedDate = null;
    } else {
      lastUsedDate = null;
    }
    return FleetUtilizationModel(
      vehicleId: json['vehicleId'] ?? 0,
      registrationNumber: json['registrationNumber'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      status: json['status'] ?? '',
      totalTrips: json['totalTrips'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      avgDistancePerTrip: (json['avgDistancePerTrip'] ?? 0).toDouble(),
      daysInWorkshop: json['daysInWorkshop'] ?? 0,
      lastUsedDate: lastUsedDate,
      enabled: json['enabled'] ?? false,
      assigned: json['assigned'] ?? false,
      inWorkshop: json['inWorkshop'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'registrationNumber': registrationNumber,
      'brand': brand,
      'model': model,
      'status': status,
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'avgDistancePerTrip': avgDistancePerTrip,
      'daysInWorkshop': daysInWorkshop,
      'lastUsedDate': lastUsedDate,
      'enabled': enabled,
      'assigned': assigned,
      'inWorkshop': inWorkshop,
    };
  }
}
