import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../../../utils/styles.dart';
import '../model/pit_stop.dart';
import '../model/route_model.dart';

class RouteDetailsDialog extends StatelessWidget {
  final RouteTripReportModel route;
  final String pitStopsStr;
  final int tripDistance;
  final double distanceCovered;

  const RouteDetailsDialog({
    super.key,
    required this.route,
    required this.pitStopsStr,
    required this.tripDistance,
    required this.distanceCovered,
  });

  @override
  Widget build(BuildContext context) {
    final pitStops = parsePitStops(pitStopsStr);
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
                      'Route #${route.routeId} Details',
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

  Widget _buildMobileLayout(List<PitStop> uniquePitStops, List<PitStop> pitStops) {
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

  Widget _buildDesktopLayout(List<PitStop> uniquePitStops, List<PitStop> pitStops) {
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
                  _buildInfoColumn('Route Type', route.routeType, Styles.primaryColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn('Total Distance', '${route.totalDistanceKm.toStringAsFixed(2)} km', Styles.tertiaryColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn('Total Requests', route.totalRequests.toString(), Styles.secondaryColor),
                ] else ...[
                  // Use row layout for larger screens
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn('Route Type', route.routeType, Styles.primaryColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Total Distance', '${route.totalDistanceKm.toStringAsFixed(2)} km', Styles.tertiaryColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Total Requests', route.totalRequests.toString(), Styles.secondaryColor),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),

                if (isVerySmall) ...[
                  // Stack vertically for very small screens
                  _buildInfoColumn('Completed', route.completedCount.toString(), Styles.successColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn('Pending', route.pendingCount.toString(), Styles.warningColor),
                  const SizedBox(height: 12),
                  _buildInfoColumn('Cancelled', route.cancelledCount.toString(), Styles.errorColor),
                ] else ...[
                  // Use row layout for larger screens
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn('Completed', route.completedCount.toString(), Styles.successColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Pending', route.pendingCount.toString(), Styles.warningColor),
                      ),
                      Expanded(
                        child: _buildInfoColumn('Cancelled', route.cancelledCount.toString(), Styles.errorColor),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            child: uniquePitStops.isNotEmpty
                ? ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    double.parse(uniquePitStops.first.latitude),
                    double.parse(uniquePitStops.first.longitude),
                  ),
                  initialZoom: _calculateOptimalZoom(_calculateRouteBounds(uniquePitStops)),
                  minZoom: 5.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // Map tiles
                  TileLayer(
                    urlTemplate: AppConfig.osmTileUrl,
                    userAgentPackageName: 'com.viaridez.corp',
                    maxZoom: 19,
                  ),

                  // Markers for pit stops
                  MarkerLayer(
                    markers: uniquePitStops.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stop = entry.value;
                      return Marker(
                        point: LatLng(
                          double.parse(stop.latitude),
                          double.parse(stop.longitude),
                        ),
                        width: 80,
                        height: 80,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
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
                            const Icon(Icons.place, color: Colors.amber, size: 30),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // Polyline connecting the route
                  if (uniquePitStops.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: uniquePitStops
                              .map((stop) => LatLng(
                            double.parse(stop.latitude),
                            double.parse(stop.longitude),
                          ))
                              .toList(),
                          strokeWidth: 4.0,
                          color: Styles.primaryColor,
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
                    Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
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

    double minLat = double.parse(pitStops.first.latitude);
    double maxLat = double.parse(pitStops.first.latitude);
    double minLng = double.parse(pitStops.first.longitude);
    double maxLng = double.parse(pitStops.first.longitude);

    for (final stop in pitStops) {
      final lat = double.parse(stop.latitude);
      final lng = double.parse(stop.longitude);

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
void showRouteDetailsDialog(
    BuildContext context,
    RouteTripReportModel route,
    String pitStopsStr,
    int tripDistance,
    double distanceCovered) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RouteDetailsDialog(
      route: route,
      pitStopsStr: pitStopsStr,
      tripDistance: tripDistance,
      distanceCovered: distanceCovered,
    ),
  );
}
