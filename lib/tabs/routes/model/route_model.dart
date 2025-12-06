class RouteTripReportModel {
  final int routeId;
  final String startLocation;
  final String endLocation;
  final String routeType;
  final bool isB2BRoute;
  final bool isB2CRoute;
  final bool isShuttleServiceRoute;
  final int totalRequests;
  final double totalDistanceKm;
  final int pendingCount;
  final int completedCount;
  final int cancelledCount;
  final double pendingDistanceKm;
  final double completedDistanceKm;
  final double cancelledDistanceKm;
  final String pitStops;

  RouteTripReportModel({
    required this.routeId,
    required this.startLocation,
    required this.endLocation,
    required this.routeType,
    required this.isB2BRoute,
    required this.isB2CRoute,
    required this.isShuttleServiceRoute,
    required this.totalRequests,
    required this.totalDistanceKm,
    required this.pendingCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.pendingDistanceKm,
    required this.completedDistanceKm,
    required this.cancelledDistanceKm,
    required this.pitStops,
  });

  factory RouteTripReportModel.fromJson(Map<String, dynamic> json) {
    return RouteTripReportModel(
      routeId: json['routeId'] ?? 0,
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      routeType: json['routeType'] ?? '',
      isB2BRoute: json['isb2bRoute'] ?? false,
      isB2CRoute: json['isb2cRoute'] ?? false,
      isShuttleServiceRoute: json['isShuttleServiceRoute'] ?? false,
      totalRequests: json['totalRequests'] ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] ?? 0).toDouble(),
      pendingCount: json['pendingCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      cancelledCount: json['cancelledCount'] ?? 0,
      pendingDistanceKm: (json['pendingDistanceKm'] ?? 0).toDouble(),
      completedDistanceKm: (json['completedDistanceKm'] ?? 0).toDouble(),
      cancelledDistanceKm: (json['cancelledDistanceKm'] ?? 0).toDouble(),
      pitStops: json['pitStops'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'routeType': routeType,
      'isb2bRoute': isB2BRoute,
      'isb2cRoute': isB2CRoute,
      'isShuttleServiceRoute': isShuttleServiceRoute,
      'totalRequests': totalRequests,
      'totalDistanceKm': totalDistanceKm,
      'pendingCount': pendingCount,
      'completedCount': completedCount,
      'cancelledCount': cancelledCount,
      'pendingDistanceKm': pendingDistanceKm,
      'completedDistanceKm': completedDistanceKm,
      'cancelledDistanceKm': cancelledDistanceKm,
      'pitStops': pitStops,
    };
  }
}
