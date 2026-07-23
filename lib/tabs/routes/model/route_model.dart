class RouteTripReportModel {
  final int routeId;
  final String startLocation;
  final String endLocation;
  final String routeType;
  final bool isB2BRoute;
  final bool isB2CRoute;
  final bool isShuttleServiceRoute;
  final double totalDistanceKm;
  final List<dynamic> pitStops; // ✅ List, not String

  // ✅ Fields not in API — kept as 0 so existing UI compiles
  final int totalRequests;
  final int completedCount;
  final int pendingCount;
  final int cancelledCount;
  final double completedDistanceKm;
  final double pendingDistanceKm;
  final double cancelledDistanceKm;

  RouteTripReportModel({
    required this.routeId,
    required this.startLocation,
    required this.endLocation,
    required this.routeType,
    required this.isB2BRoute,
    required this.isB2CRoute,
    required this.isShuttleServiceRoute,
    required this.totalDistanceKm,
    required this.pitStops,
    this.totalRequests = 0,
    this.completedCount = 0,
    this.pendingCount = 0,
    this.cancelledCount = 0,
    this.completedDistanceKm = 0.0,
    this.pendingDistanceKm = 0.0,
    this.cancelledDistanceKm = 0.0,
  });

  // ✅ Convenience getters for data source
  int get pitStopsCount => pitStops.length;
  String get pitStopsStr => pitStops
      .map((s) => s['name']?.toString() ?? '')
      .where((n) => n.isNotEmpty)
      .join(', ');

  factory RouteTripReportModel.fromJson(Map<String, dynamic> json) {
    return RouteTripReportModel(
      routeId: json['id'] ?? 0,                          // ✅ API uses 'id'
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      routeType: json['routeType'] ?? '',
      isB2BRoute: json['b2bRoute'] ?? false,
      isB2CRoute: json['b2cRoute'] ?? false,
      isShuttleServiceRoute: json['shuttleServiceRoute'] ?? false,
      totalDistanceKm: (json['totalDistanceKm'] ?? 0).toDouble(),
      pitStops: json['pitStops'] is List
          ? List<dynamic>.from(json['pitStops'] as List)
          : [],
      // API fields not present — stay as defaults (0)
    );
  }
}