import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/models.dart';
import '../../../../utils/styles.dart';

class TripReportDialog extends StatefulWidget {
  final List<TripReportModel> trips;

  const TripReportDialog({
    super.key,
    required this.trips,
  });

  @override
  State<TripReportDialog> createState() => _TripReportDialogState();
}

class _TripReportDialogState extends State<TripReportDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<TripReportModel> _filteredTrips = [];
  bool _showMap = false;
  TripReportModel? _selectedTrip;

  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  int _totalPages = 0;
  List<TripReportModel> _currentPageTrips = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredTrips = widget.trips;
    _updatePagination();
    _searchController.addListener(() {
      _filterTrips(_searchController.text);
    });
  }

  void _updatePagination() {
    _totalPages = (_filteredTrips.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    // Ensure current page is within bounds
    if (_currentPage >= _totalPages) {
      _currentPage = _totalPages - 1;
    }
    if (_currentPage < 0) _currentPage = 0;

    // Get trips for current page
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, _filteredTrips.length);
    _currentPageTrips = _filteredTrips.sublist(startIndex, endIndex);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTrips(String query) async {
    setState(() {
      _isLoading = true;
    });

    // Add a small delay for very large datasets
    if (widget.trips.length > 500) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() {
      if (query.isEmpty) {
        _filteredTrips = widget.trips;
      } else {
        _filteredTrips = widget.trips
            .where((trip) =>
                (trip.driverName.isNotEmpty &&
                    trip.driverName
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (trip.vehicleNumber.isNotEmpty &&
                    trip.vehicleNumber
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (trip.startLocation.isNotEmpty &&
                    trip.startLocation
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (trip.endLocation.isNotEmpty &&
                    trip.endLocation
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (trip.tripId?.isNotEmpty == true &&
                    trip.tripId!.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
      _currentPage = 0; // Reset to first page when filtering
      _updatePagination();
      _isLoading = false;
    });
  }

  void _toggleMapView({TripReportModel? trip}) {
    setState(() {
      _showMap = !_showMap;
      _selectedTrip = trip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Styles.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Styles.primaryColor,
                    Styles.secondaryColor,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _showMap ? Icons.map : Icons.directions_car,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showMap
                              ? 'Trip Route View'
                              : 'Trip Reports Analytics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _showMap
                              ? 'Interactive map with trip routes and locations'
                              : 'Comprehensive trip tracking and performance insights',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_showMap)
                    IconButton(
                      onPressed: () => _toggleMapView(),
                      icon:
                          const Icon(Icons.map, color: Colors.white, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      tooltip: 'View Routes on Map',
                    ),
                  if (_showMap)
                    IconButton(
                      onPressed: () => _toggleMapView(),
                      icon: const Icon(Icons.table_chart,
                          color: Colors.white, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      tooltip: 'View Analytics',
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _showMap
                  ? _buildMapView()
                  : widget.trips.isEmpty
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Statistics Cards Row
                              _buildStatsCards(),
                              const SizedBox(height: 32),

                              // Charts Section
                              _buildChartsSection(),
                              const SizedBox(height: 32),

                              // Detailed Data Table
                              _buildModernDataTable(),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.route_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Trip Data Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trip reports and analytics will appear here once data is available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: 'Lexend',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Map Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Styles.primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedTrip != null
                        ? 'Showing route for Trip: ${_selectedTrip!.tripId ?? 'N/A'} - ${_selectedTrip!.clientName}'
                        : 'Select a trip from the table to view its route on the map',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                if (_selectedTrip != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedTrip = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Styles.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Map Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    center: _selectedTrip != null &&
                            _selectedTrip!.startLat != 0.0 &&
                            _selectedTrip!.startLong != 0.0
                        ? LatLng(
                            _selectedTrip!.startLat, _selectedTrip!.startLong)
                        : LatLng(12.9716,
                            77.5946), // Default to Bangalore coordinates
                    zoom: _selectedTrip != null ? 14.0 : 11.0,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConfig.osmTileUrl,
                      userAgentPackageName: 'com.viaridez.app',
                      maxZoom: 19,
                    ),
                    if (_selectedTrip != null) ...[
                      // Route markers and polylines would go here
                      MarkerLayer(
                        markers: _buildTripMarkers(_selectedTrip!),
                      ),
                      PolylineLayer(
                        polylines: _buildTripRoutes(_selectedTrip!),
                      ),
                    ] else ...[
                      // Show all trip locations when no specific trip is selected
                      MarkerLayer(
                        markers: _buildAllTripsMarkers(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Map Legend
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                    Icons.location_on, 'Start Point', Colors.green),
                _buildLegendItem(Icons.flag, 'End Point', Colors.red),
                _buildLegendItem(Icons.route, 'Route Path', Colors.blue),
                _buildLegendItem(
                    Icons.location_city, 'Waypoints', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  List<Marker> _buildTripMarkers(TripReportModel trip) {
    // Use actual coordinates from the trip data
    return [
      if (trip.startLat != 0.0 && trip.startLong != 0.0)
        Marker(
          point: LatLng(trip.startLat, trip.startLong), // Start point
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
        ),
      if (trip.endLat != 0.0 && trip.endLong != 0.0)
        Marker(
          point: LatLng(trip.endLat, trip.endLong), // End point
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.flag, color: Colors.white, size: 20),
          ),
        ),
    ];
  }

  List<Polyline> _buildTripRoutes(TripReportModel trip) {
    // Use actual route coordinates from trip data
    if (trip.startLat != 0.0 &&
        trip.startLong != 0.0 &&
        trip.endLat != 0.0 &&
        trip.endLong != 0.0) {
      return [
        Polyline(
          points: [
            LatLng(trip.startLat, trip.startLong),
            LatLng(trip.endLat, trip.endLong),
          ],
          strokeWidth: 4.0,
          color: Colors.blue,
        ),
      ];
    }
    return [];
  }

  List<Marker> _buildAllTripsMarkers() {
    // Show markers for current page trips only to improve performance
    return _currentPageTrips
        .where((trip) => trip.startLat != 0.0 && trip.startLong != 0.0)
        .map((trip) {
      return Marker(
        point: LatLng(trip.startLat, trip.startLong),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => setState(() => _selectedTrip = trip),
          child: Container(
            decoration: BoxDecoration(
              color: _getTripStatusColor(trip.tripStatus),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child:
                const Icon(Icons.directions_car, color: Colors.white, size: 16),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            title: 'Total Trips',
            value: _filteredTrips.length.toString(),
            color: Colors.blue,
            subtitle: 'All trips',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            title: 'Completed',
            value: _getCompletedCount().toString(),
            color: Colors.green,
            subtitle: 'Successful trips',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            title: 'In Progress',
            value: _getInProgressCount().toString(),
            color: Colors.orange,
            subtitle: 'Active trips',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.cancel,
            title: 'Cancelled',
            value: _getCancelledCount().toString(),
            color: Colors.red,
            subtitle: 'Cancelled trips',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTripStatusChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildPassengerUtilizationChart(),
        ),
      ],
    );
  }

  Widget _buildTripStatusChart() {
    if (_filteredTrips.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('No data to display'),
        ),
      );
    }

    List<_ChartData> chartData = [
      _ChartData('Completed', _getCompletedCount().toDouble(), Colors.green),
      _ChartData(
          'In Progress', _getInProgressCount().toDouble(), Colors.orange),
      _ChartData('Cancelled', _getCancelledCount().toDouble(), Colors.red),
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lexend',
                ),
              ),
              series: <PieSeries<_ChartData, String>>[
                PieSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData data, _) => data.category,
                  yValueMapper: (_ChartData data, _) => data.value,
                  pointColorMapper: (_ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 10,
                    ),
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerUtilizationChart() {
    var utilizationData = _filteredTrips.map((trip) {
      final utilization = trip.totalPassengers > 0
          ? (trip.presentPassengers / trip.totalPassengers * 100)
          : 0.0;
      return {
        'trip': trip,
        'utilization': utilization,
      };
    }).toList()
      ..sort((a, b) =>
          (b['utilization'] as double).compareTo(a['utilization'] as double));

    if (utilizationData.length > 5) {
      utilizationData = utilizationData.take(5).toList();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Passenger Utilization',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  fontFamily: 'Lexend',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${utilizationData.length} trips',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: utilizationData.isEmpty
                ? Center(
                    child: Text(
                      'No utilization data available',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: utilizationData.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data = utilizationData[index];
                      final trip = data['trip'] as TripReportModel;
                      final utilization = data['utilization'] as double;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  _getUtilizationColor(utilization),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.clientName.isNotEmpty
                                        ? trip.clientName
                                        : 'Unknown Client',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                  Text(
                                    '${trip.presentPassengers}/${trip.totalPassengers} passengers',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${utilization.toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getUtilizationColor(utilization),
                                fontSize: 12,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDataTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Detailed Trip Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(width: 8),
                // if (_filteredTrips.length > _itemsPerPage)
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //     decoration: BoxDecoration(
                //       color: Colors.orange.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Text(
                //       'Paginated',
                //       style: TextStyle(
                //         fontSize: 10,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.orange.shade700,
                //         fontFamily: 'Lexend',
                //       ),
                //     ),
                //   ),
                const Spacer(),
                // Search Bar
                Container(
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, fontFamily: 'Lexend'),
                    decoration: InputDecoration(
                      hintText: 'Search trips, drivers, vehicles...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontFamily: 'Lexend',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Styles.primaryColor,
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          _filteredTrips.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No trips found matching "${_searchController.text}"'
                          : 'No trip data available',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Pagination Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Showing ${(_currentPage * _itemsPerPage) + 1}-${((_currentPage + 1) * _itemsPerPage).clamp(0, _filteredTrips.length)} of ${_filteredTrips.length} trips',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          const Spacer(),
                          if (_filteredTrips.length > _itemsPerPage)
                            _buildPaginationControls(),
                        ],
                      ),
                    ),

                    // Data Table
                    Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: DataTable(
                            headingRowHeight: 56,
                            dataRowHeight: 64,
                            columnSpacing: 24,
                            headingRowColor: MaterialStateProperty.all(
                              Styles.primaryColor.withOpacity(0.05),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Trip ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Driver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Vehicle',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Passengers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Styles.primaryColor,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                            ],
                            rows: _currentPageTrips
                                .map((trip) => DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            trip.tripId ?? 'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Lexend',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            trip.driverName.isNotEmpty
                                                ? trip.driverName
                                                : 'Unknown Driver',
                                            style: const TextStyle(
                                                fontFamily: 'Lexend'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            trip.vehicleNumber.isNotEmpty
                                                ? trip.vehicleNumber
                                                : 'N/A',
                                            style: const TextStyle(
                                                fontFamily: 'Lexend'),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${trip.presentPassengers}/${trip.totalPassengers}',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                fontFamily: 'Lexend',
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(_buildModernStatusChip(
                                            trip.tripStatus)),
                                        DataCell(
                                          Text(
                                            _formatTime(trip.startTime),
                                            style: const TextStyle(
                                                fontFamily: 'Lexend'),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            onPressed: () =>
                                                _toggleMapView(trip: trip),
                                            icon:
                                                const Icon(Icons.map, size: 20),
                                            style: IconButton.styleFrom(
                                              backgroundColor: Styles
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              foregroundColor:
                                                  Styles.primaryColor,
                                            ),
                                            tooltip: 'View on Map',
                                          ),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First page button
        IconButton(
          onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
          icon: const Icon(Icons.first_page, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 0 ? Colors.grey.shade100 : null,
            foregroundColor:
                _currentPage > 0 ? Styles.primaryColor : Colors.grey.shade400,
          ),
          tooltip: 'First page',
        ),

        // Previous page button
        IconButton(
          onPressed:
              _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 0 ? Colors.grey.shade100 : null,
            foregroundColor:
                _currentPage > 0 ? Styles.primaryColor : Colors.grey.shade400,
          ),
          tooltip: 'Previous page',
        ),

        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Styles.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Styles.primaryColor,
              fontFamily: 'Lexend',
            ),
          ),
        ),

        // Next page button
        IconButton(
          onPressed: _currentPage < _totalPages - 1
              ? () => _goToPage(_currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          style: IconButton.styleFrom(
            backgroundColor:
                _currentPage < _totalPages - 1 ? Colors.grey.shade100 : null,
            foregroundColor: _currentPage < _totalPages - 1
                ? Styles.primaryColor
                : Colors.grey.shade400,
          ),
          tooltip: 'Next page',
        ),

        // Last page button
        IconButton(
          onPressed: _currentPage < _totalPages - 1
              ? () => _goToPage(_totalPages - 1)
              : null,
          icon: const Icon(Icons.last_page, size: 18),
          style: IconButton.styleFrom(
            backgroundColor:
                _currentPage < _totalPages - 1 ? Colors.grey.shade100 : null,
            foregroundColor: _currentPage < _totalPages - 1
                ? Styles.primaryColor
                : Colors.grey.shade400,
          ),
          tooltip: 'Last page',
        ),
      ],
    );
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _updatePagination();
    });
  }

  Widget _buildModernStatusChip(String status) {
    Color color = _getTripStatusColor(status);
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        icon = Icons.check_circle;
        break;
      case 'in_progress':
      case 'in progress':
        icon = Icons.schedule;
        break;
      case 'cancelled':
        icon = Icons.cancel;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Color _getTripStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'in progress':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 90) return Colors.green;
    if (utilization >= 70) return Colors.blue;
    if (utilization >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(List<int> timeArray) {
    if (timeArray.isEmpty || timeArray.length < 3) return 'N/A';

    try {
      final year = timeArray[0];
      final month = timeArray[1];
      final day = timeArray[2];
      final hour = timeArray.length > 3 ? timeArray[3] : 0;
      final minute = timeArray.length > 4 ? timeArray[4] : 0;

      return '$day/${month.toString().padLeft(2, '0')}/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid time';
    }
  }

  int _getCompletedCount() {
    return _filteredTrips
        .where((trip) => trip.tripStatus.toLowerCase() == 'completed')
        .length;
  }

  int _getInProgressCount() {
    return _filteredTrips
        .where((trip) =>
            trip.tripStatus.toLowerCase() == 'in_progress' ||
            trip.tripStatus.toLowerCase() == 'in progress')
        .length;
  }

  int _getCancelledCount() {
    return _filteredTrips
        .where((trip) => trip.tripStatus.toLowerCase() == 'cancelled')
        .length;
  }
}

class _ChartData {
  _ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
