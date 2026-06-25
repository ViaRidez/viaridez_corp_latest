class RouteModel {
  final int routeId;
  final String routeName;
  final String startLocation;
  final String endLocation;
  final String routeType;
  final String? clientName;
  final bool isActive;
  final bool isB2BRoute;
  final bool isB2CRoute;
  final bool isShuttleServiceRoute;
  final int? totalRequests;
  final double? totalDistanceKm;
  final String? pitStops;

  RouteModel({
    required this.routeId,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    required this.routeType,
    this.clientName,
    this.isActive = true,
    this.isB2BRoute = false,
    this.isB2CRoute = false,
    this.isShuttleServiceRoute = false,
    this.totalRequests,
    this.totalDistanceKm,
    this.pitStops,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get string values
    String _safeGetString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    final startLoc = _safeGetString(json['startLocation'], '');
    final endLoc = _safeGetString(json['endLocation'], '');
    final routeId = json['routeId'] ?? json['id'] ?? 0;

    return RouteModel(
      routeId: routeId,
      routeName: json['routeName'] ??
    'Route $routeId',
      startLocation: startLoc,
      endLocation: endLoc,
      routeType: _safeGetString(json['routeType'], ''),
      clientName: json['clientName'],
      isActive: json['isActive'] ?? true,
      isB2BRoute: json['isb2bRoute'] ?? json['isB2BRoute'] ?? false,
      isB2CRoute: json['isb2cRoute'] ?? json['isB2CRoute'] ?? false,
      isShuttleServiceRoute: json['isShuttleServiceRoute'] ?? false,
      totalRequests: json['totalRequests'],
      totalDistanceKm: json['totalDistanceKm']?.toDouble(),
      pitStops: (json['pitStops'] as List?)
    ?.map((e) => e['name'].toString())
    .join('|'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'routeType': routeType,
      'clientName': clientName,
      'isActive': isActive,
      'isB2BRoute': isB2BRoute,
      'isB2CRoute': isB2CRoute,
      'isShuttleServiceRoute': isShuttleServiceRoute,
      'totalRequests': totalRequests,
      'totalDistanceKm': totalDistanceKm,
      'pitStops': pitStops,
    };
  }

  // Helper function to get short location names for display
  String _getShortLocationName(String fullLocation) {
    if (fullLocation.isEmpty) return fullLocation;

    // Extract the first meaningful part before the first comma
    final parts = fullLocation.split(',');
    if (parts.isNotEmpty) {
      String firstPart = parts[0].trim();
      // If the first part is too long, try to get a shorter version
      if (firstPart.length > 30 && parts.length > 1) {
        // Try to find a more meaningful part
        for (int i = 1; i < parts.length; i++) {
          String part = parts[i].trim();
          if (part.length < 30 && part.length > 5) {
            return part;
          }
        }
      }
      return firstPart.length > 50
          ? '${firstPart.substring(0, 47)}...'
          : firstPart;
    }
    return fullLocation;
  }

  // Getters for short location names
  String get shortStartLocation => _getShortLocationName(startLocation);
  String get shortEndLocation => _getShortLocationName(endLocation);

  // Helper to get parsed pitstop names
  List<String> get parsedPitStops {
    if (pitStops == null || pitStops!.isEmpty) return [];

    return pitStops!
        .split('|')
        .map((stop) => stop.trim())
        .where((stop) => stop.isNotEmpty)
        .map((stop) {
          // Extract location name before the coordinates
          final openParenIndex = stop.indexOf('(');
          if (openParenIndex > 0) {
            return stop.substring(0, openParenIndex).trim();
          }
          return stop.trim();
        })
        .where((name) => name.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
  }

  // Helper to get formatted pitstops string for display
  String get formattedPitStops {
    final stops = parsedPitStops;
    if (stops.isEmpty) return '';
    if (stops.length <= 3) {
      return stops.join(' → ');
    }
    return '${stops.take(3).join(' → ')} +${stops.length - 3} more';
  }

  String get displayName =>
      '$routeName ($shortStartLocation → $shortEndLocation)';
  String get fullDisplayName => '$routeName ($startLocation → $endLocation)';
  String get routeTypeDisplay =>
      routeType.isEmpty ? 'Standard' : routeType.toUpperCase();

  @override
  String toString() {
    return 'RouteModel(id: $routeId, name: $routeName, from: $startLocation, to: $endLocation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteModel && other.routeId == routeId;
  }

  @override
  int get hashCode => routeId.hashCode;
}
