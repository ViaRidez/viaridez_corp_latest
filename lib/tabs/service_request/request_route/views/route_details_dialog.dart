import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../../utils/styles.dart';
import '../model/route_requested_model.dart';

class RouteDetailsDialog extends StatelessWidget {
  final RouteRequestedModel route;

  const RouteDetailsDialog({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final pitStops = route.pitStops;
    final uniquePitStops = _getUniquePitStops(pitStops);
    final bounds = _calculateRouteBounds(uniquePitStops);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 16 : 24,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenSize.width * 0.95 : 1200,
          maxHeight: isSmallScreen ? screenSize.height * 0.9 : 800,
          minWidth: isSmallScreen ? screenSize.width * 0.9 : 600,
          minHeight: isSmallScreen ? 400 : 500,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Route #${route.id} Details',
                      style: TextStyles.sectionTitle.copyWith(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isSmallScreen
                  ? _buildMobileLayout(uniquePitStops, pitStops)
                  : _buildDesktopLayout(uniquePitStops, pitStops),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      List<PitStop> uniquePitStops, List<PitStop> pitStops) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Styles.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Styles.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Details'),
              Tab(icon: Icon(Icons.map), text: 'Map'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRouteInformationPanel(pitStops),
                _buildMapPanel(uniquePitStops),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      List<PitStop> uniquePitStops, List<PitStop> pitStops) {
    return Row(
      children: [
        // Left panel - Route information
        Expanded(
          flex: 3,
          child: _buildRouteInformationPanel(pitStops),
        ),
        // Vertical divider
        Container(
          width: 1,
          color: Colors.grey.shade200,
        ),
        // Right panel - Interactive Map
        Expanded(
          flex: 4,
          child: _buildMapPanel(uniquePitStops),
        ),
      ],
    );
  }

  Widget _buildRouteInformationPanel(List<PitStop> pitStops) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary card
          _buildRouteSummaryCard(),
          const SizedBox(height: 16),
          // Route information card
          _buildRouteInformationCard(),
          const SizedBox(height: 16),
          // Route details section
          _buildRouteDetailsSection(pitStops),
        ],
      ),
    );
  }

  Widget _buildRouteSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isVerySmall = constraints.maxWidth < 400;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Summary',
                  style: TextStyles.cardTitle,
                ),
                const SizedBox(height: 16),
                if (isVerySmall) ...[
                  // Stack vertically for very small screens
                  _buildInfoColumn(
                      'Route Type', route.routeType, Styles.primaryColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn(
                      'Total Distance',
                      '${route.totalDistanceKm.toStringAsFixed(2)} km',
                      Styles.tertiaryColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn(
                      'Client Name', route.clientName, Styles.secondaryColor),
                ] else ...[
                  // Use row layout for larger screens
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                            'Route Type', route.routeType, Styles.primaryColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                            'Total Distance',
                            '${route.totalDistanceKm.toStringAsFixed(2)} km',
                            Styles.tertiaryColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Client Name', route.clientName,
                            Styles.secondaryColor),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),
                if (isVerySmall) ...[
                  // Stack vertically for very small screens
                  _buildInfoColumn(
                      'Requested By', route.requestedBy, Styles.successColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn('Estimated Time',
                      route.estimatedTime ?? 'N/A', Styles.warningColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn(
                      'Route For', route.routeFor ?? 'N/A', Styles.errorColor),
                ] else ...[
                  // Use row layout for larger screens
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn('Requested By',
                            route.requestedBy, Styles.successColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Estimated Time',
                            route.estimatedTime ?? 'N/A', Styles.warningColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Route For',
                            route.routeFor ?? 'N/A', Styles.errorColor),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteInformationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Information',
                  style: TextStyles.cardTitle,
                ),
                const SizedBox(height: 16),
                _buildDetailRow('ID', route.id.toString(), constraints),
                _buildDetailRow(
                    'Created At',
                    DateFormat('MMM dd, yyyy HH:mm').format(route.createdAt),
                    constraints),
                _buildDetailRow(
                    'Updated At',
                    DateFormat('MMM dd, yyyy HH:mm').format(route.updatedAt),
                    constraints),
                _buildDetailRow('Action Taken By', route.actionTakenBy ?? 'N/A',
                    constraints),
                _buildDetailRow('Status', route.statusName, constraints),
                const SizedBox(height: 16),
                Text(
                  'Route Flags',
                  style: TextStyles.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (route.b2bRoute)
                      Chip(
                        label: Text('B2B Route', style: TextStyles.chipText),
                        backgroundColor: Colors.blue[100],
                      ),
                    if (route.b2cRoute)
                      Chip(
                        label: Text('B2C Route', style: TextStyles.chipText),
                        backgroundColor: Colors.green[100],
                      ),
                    if (route.shuttleServiceRoute)
                      Chip(
                        label:
                            Text('Shuttle Service', style: TextStyles.chipText),
                        backgroundColor: Colors.orange[100],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteDetailsSection(List<PitStop> pitStops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Details',
          style: TextStyles.sectionTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Start point
        _buildRoutePointCard(
          'Start Point',
          route.startLocation,
          Icons.trip_origin,
          Colors.green,
        ),

        // All Pitstops
        if (pitStops.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'All Pitstops (${pitStops.length} total)',
            style: TextStyles.subsectionTitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...pitStops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildRoutePointCard(
                'Pitstop ${index + 1}',
                '${stop.name}\nCoordinates: ${stop.latitude}, ${stop.longitude}',
                Icons.place,
                Colors.amber,
              ),
            );
          }).toList(),
        ],

        // End point
        const SizedBox(height: 8),
        _buildRoutePointCard(
          'End Point',
          route.endLocation,
          Icons.location_on,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildMapPanel(List<PitStop> uniquePitStops) {
    // Build complete route points including start and end
    final List<LatLng> routePoints = [];

    // Add start point
    if (route.startLatitude != 0.0 && route.startLongitude != 0.0) {
      routePoints.add(LatLng(route.startLatitude, route.startLongitude));
    }

    // Add pit stops
    for (final stop in uniquePitStops) {
      routePoints.add(LatLng(stop.latitude, stop.longitude));
    }

    // Add end point
    if (route.endLatitude != 0.0 && route.endLongitude != 0.0) {
      routePoints.add(LatLng(route.endLatitude, route.endLongitude));
    }

    final hasRouteData = routePoints.isNotEmpty;
    final bounds = _calculateCompleteRouteBounds();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // Map header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.map, color: Styles.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Route Map',
                    style: TextStyles.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (uniquePitStops.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${uniquePitStops.length} stops',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Interactive Map
          Expanded(
            child: hasRouteData
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: routePoints.first,
                        initialZoom: _calculateOptimalZoom(bounds),
                        minZoom: 5.0,
                        maxZoom: 18.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        // Map tiles
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.viaridez.corp',
                          maxZoom: 19,
                        ),

                        // Polyline connecting the complete route
                        if (routePoints.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                strokeWidth: 4.0,
                                color: Styles.primaryColor,
                              ),
                            ],
                          ),

                        // Markers
                        MarkerLayer(
                          markers: [
                            // Start point marker
                            if (route.startLatitude != 0.0 &&
                                route.startLongitude != 0.0)
                              Marker(
                                point: LatLng(
                                    route.startLatitude, route.startLongitude),
                                width: 80,
                                height: 80,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Start',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Icon(Icons.trip_origin,
                                        color: Colors.green, size: 30),
                                  ],
                                ),
                              ),

                            // Pit stop markers
                            ...uniquePitStops.asMap().entries.map((entry) {
                              final index = entry.key;
                              final stop = entry.value;
                              return Marker(
                                point: LatLng(stop.latitude, stop.longitude),
                                width: 80,
                                height: 80,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Stop ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Icon(Icons.place,
                                        color: Colors.amber, size: 30),
                                  ],
                                ),
                              );
                            }).toList(),

                            // End point marker
                            if (route.endLatitude != 0.0 &&
                                route.endLongitude != 0.0)
                              Marker(
                                point: LatLng(
                                    route.endLatitude, route.endLongitude),
                                width: 80,
                                height: 80,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'End',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Icon(Icons.location_on,
                                        color: Colors.red, size: 30),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No Route Data',
                            style: TextStyles.sectionTitle.copyWith(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'No pit stop coordinates available to display the map.',
                              textAlign: TextAlign.center,
                              style: TextStyles.bodyText.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Updated responsive _buildDetailRow method
  Widget _buildDetailRow(
      String label, String value, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 300;

    if (isSmallScreen) {
      // Stack vertically on very small screens
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label:',
              style: TextStyles.dataLabel.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyles.dataValue.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      );
    } else {
      // Use row layout for larger screens
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: TextStyles.dataLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyles.dataValue.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.dataLabel,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyles.dataValue.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutePointCard(
    String title,
    String location,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyles.bodyText.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Keep your existing helper methods unchanged
  List<PitStop> _getUniquePitStops(List<PitStop> pitStops) {
    final seen = <String>{};
    return pitStops.where((stop) {
      final key = '${stop.latitude},${stop.longitude}';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  Map<String, double> _calculateRouteBounds(List<PitStop> pitStops) {
    if (pitStops.isEmpty) {
      return {
        'minLat': 0.0,
        'maxLat': 0.0,
        'minLng': 0.0,
        'maxLng': 0.0,
      };
    }

    double minLat = pitStops.first.latitude;
    double maxLat = pitStops.first.latitude;
    double minLng = pitStops.first.longitude;
    double maxLng = pitStops.first.longitude;

    for (final stop in pitStops) {
      final lat = stop.latitude;
      final lng = stop.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  Map<String, double> _calculateCompleteRouteBounds() {
    // Collect all points (start, pitstops, end)
    List<LatLng> allPoints = [];

    // Add start point
    if (route.startLatitude != 0.0 && route.startLongitude != 0.0) {
      allPoints.add(LatLng(route.startLatitude, route.startLongitude));
    }

    // Add pit stops
    for (final stop in route.pitStops) {
      allPoints.add(LatLng(stop.latitude, stop.longitude));
    }

    // Add end point
    if (route.endLatitude != 0.0 && route.endLongitude != 0.0) {
      allPoints.add(LatLng(route.endLatitude, route.endLongitude));
    }

    if (allPoints.isEmpty) {
      return {
        'minLat': 0.0,
        'maxLat': 0.0,
        'minLng': 0.0,
        'maxLng': 0.0,
      };
    }

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final point in allPoints) {
      final lat = point.latitude;
      final lng = point.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  double _calculateOptimalZoom(Map<String, double> bounds) {
    if (bounds['minLat'] == 0.0 && bounds['maxLat'] == 0.0) {
      return 13.0;
    }

    final latDiff = bounds['maxLat']! - bounds['minLat']!;
    final lngDiff = bounds['maxLng']! - bounds['minLng']!;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 1.0) return 8.0;
    if (maxDiff > 0.5) return 10.0;
    if (maxDiff > 0.1) return 12.0;
    if (maxDiff > 0.05) return 13.0;
    if (maxDiff > 0.01) return 14.0;
    return 15.0;
  }
}

// Updated utility function
void showRouteDetailsDialog(BuildContext context, RouteRequestedModel route) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RouteDetailsDialog(route: route),
  );
}
