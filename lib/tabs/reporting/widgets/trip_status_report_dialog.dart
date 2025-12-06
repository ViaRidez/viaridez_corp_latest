import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/models.dart';

class TripStatusReportDialog extends StatefulWidget {
  final List<TripStatusReportModel> trips;
  final String status;

  const TripStatusReportDialog({
    super.key,
    required this.trips,
    required this.status,
  });

  @override
  State<TripStatusReportDialog> createState() => _TripStatusReportDialogState();
}

class _TripStatusReportDialogState extends State<TripStatusReportDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<TripStatusReportModel> _filteredTrips = [];
  bool _isLoading = false;

  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  int _totalPages = 0;
  List<TripStatusReportModel> _currentPageTrips = [];

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
                (trip.tripId?.isNotEmpty == true &&
                    trip.tripId!.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
      _currentPage = 0; // Reset to first page when filtering
      _updatePagination();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(widget.status);

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
              statusInfo.color.withOpacity(0.05),
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
                    statusInfo.color,
                    statusInfo.color.withOpacity(0.8),
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
                      statusInfo.icon,
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
                          '${statusInfo.title} Trip Reports',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detailed analytics and insights for ${statusInfo.title.toLowerCase()} trips',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
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
              child: widget.trips.isEmpty
                  ? _buildEmptyState(statusInfo)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Statistics Cards Row
                          _buildStatsCards(statusInfo),
                          const SizedBox(height: 32),

                          // Charts Section
                          _buildChartsSection(),
                          const SizedBox(height: 32),

                          // Detailed Data Table
                          _buildModernDataTable(statusInfo),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo.icon,
              size: 64,
              color: statusInfo.color.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No ${statusInfo.title} Trips Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${statusInfo.title} trip reports will appear here once data is available',
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

  Widget _buildStatsCards(StatusInfo statusInfo) {
    final totalTrips = _filteredTrips.length;
    final todayTrips = _filteredTrips.where((trip) => trip.isToday).length;
    final totalPassengers = _filteredTrips.fold<int>(
        0, (sum, trip) => sum + trip.presentPassengers);
    final avgDuration = _calculateAverageDuration();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment,
            title: 'Total Trips',
            value: totalTrips.toString(),
            color: statusInfo.color,
            subtitle: '${statusInfo.title} trips',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            title: 'Today',
            value: todayTrips.toString(),
            color: Colors.blue,
            subtitle: 'Trips today',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'Passengers',
            value: totalPassengers.toString(),
            color: Colors.green,
            subtitle: 'Total transported',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            title: 'Avg Duration',
            value: avgDuration,
            color: Colors.orange,
            subtitle: 'Per trip',
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
          child: _buildPassengerUtilizationChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildDailyDistributionChart(),
        ),
      ],
    );
  }

  Widget _buildPassengerUtilizationChart() {
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

    var utilizationData = _filteredTrips.map((trip) {
      final utilization = trip.totalPassengers > 0
          ? (trip.presentPassengers / trip.totalPassengers * 100)
          : 0.0;
      return _ChartData(
        '${trip.tripId ?? 'Trip ${trip.id}'}',
        utilization,
        _getUtilizationColor(utilization),
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (utilizationData.length > 10) {
      utilizationData = utilizationData.take(10).toList();
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
          Text(
            'Passenger Utilization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 10, fontFamily: 'Lexend'),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 10, fontFamily: 'Lexend'),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Colors.grey,
                ),
                title: AxisTitle(
                  text: 'Utilization %',
                  textStyle:
                      const TextStyle(fontSize: 12, fontFamily: 'Lexend'),
                ),
              ),
              series: <ColumnSeries<_ChartData, String>>[
                ColumnSeries<_ChartData, String>(
                  dataSource: utilizationData,
                  xValueMapper: (_ChartData data, _) => data.category,
                  yValueMapper: (_ChartData data, _) => data.value,
                  pointColorMapper: (_ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 8, fontFamily: 'Lexend'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyDistributionChart() {
    final dailyData = <String, int>{};
    final now = DateTime.now();

    // Initialize with last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      dailyData[key] = 0;
    }

    // Count trips by day
    for (final trip in _filteredTrips) {
      final startDate = trip.startDateTime;
      if (startDate != null) {
        final key = '${startDate.day}/${startDate.month}';
        if (dailyData.containsKey(key)) {
          dailyData[key] = dailyData[key]! + 1;
        }
      }
    }

    final chartData = dailyData.entries
        .map((entry) => _ChartData(
              entry.key,
              entry.value.toDouble(),
              _getStatusInfo(widget.status).color,
            ))
        .toList();

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
            'Daily Distribution (Last 7 Days)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 10, fontFamily: 'Lexend'),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(fontSize: 10, fontFamily: 'Lexend'),
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Colors.grey,
                ),
                title: AxisTitle(
                  text: 'Trips',
                  textStyle:
                      const TextStyle(fontSize: 12, fontFamily: 'Lexend'),
                ),
              ),
              series: <LineSeries<_ChartData, String>>[
                LineSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData data, _) => data.category,
                  yValueMapper: (_ChartData data, _) => data.value,
                  color: _getStatusInfo(widget.status).color,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 8, fontFamily: 'Lexend'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDataTable(StatusInfo statusInfo) {
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
                  'Detailed ${statusInfo.title} Trip Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                    fontFamily: 'Lexend',
                  ),
                ),
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
                                  color: statusInfo.color,
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
                            _buildPaginationControls(statusInfo),
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
                              statusInfo.color.withOpacity(0.05),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Trip ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Driver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Vehicle',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Passengers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Start Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'End Time',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo.color,
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
                                            trip.tripId ?? 'Trip ${trip.id}',
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
                                                : 'Not Assigned',
                                            style: TextStyle(
                                              fontFamily: 'Lexend',
                                              color: trip.driverName.isNotEmpty
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            trip.vehicleNumber.isNotEmpty
                                                ? trip.vehicleNumber
                                                : 'Not Assigned',
                                            style: TextStyle(
                                              fontFamily: 'Lexend',
                                              color:
                                                  trip.vehicleNumber.isNotEmpty
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade400,
                                            ),
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
                                        DataCell(
                                          Text(
                                            _formatTime(trip.startTime),
                                            style: const TextStyle(
                                                fontFamily: 'Lexend'),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatTime(trip.endTime),
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
                                              color: statusInfo.color
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              trip.formattedDuration,
                                              style: TextStyle(
                                                color: statusInfo.color,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                fontFamily: 'Lexend',
                                              ),
                                            ),
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

  Widget _buildPaginationControls(StatusInfo statusInfo) {
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
                _currentPage > 0 ? statusInfo.color : Colors.grey.shade400,
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
                _currentPage > 0 ? statusInfo.color : Colors.grey.shade400,
          ),
          tooltip: 'Previous page',
        ),

        // Page indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: statusInfo.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusInfo.color,
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
                ? statusInfo.color
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
                ? statusInfo.color
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

  String _calculateAverageDuration() {
    if (_filteredTrips.isEmpty) return '0m';

    final totalMinutes = _filteredTrips.fold<int>(0, (sum, trip) {
      final start = trip.startDateTime;
      final end = trip.endDateTime;
      if (start != null && end != null) {
        return sum + end.difference(start).inMinutes;
      }
      return sum;
    });

    final avgMinutes = totalMinutes / _filteredTrips.length;
    final hours = avgMinutes ~/ 60;
    final minutes = (avgMinutes % 60).round();

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 90) return Colors.green;
    if (utilization >= 70) return Colors.blue;
    if (utilization >= 50) return Colors.orange;
    return Colors.red;
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusInfo(
          title: 'Completed',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        );
      case 'pending':
        return StatusInfo(
          title: 'Pending',
          icon: Icons.schedule_rounded,
          color: Colors.orange,
        );
      case 'unallocated':
        return StatusInfo(
          title: 'Unallocated',
          icon: Icons.assignment_late_rounded,
          color: Colors.blue,
        );
      case 'cancelled':
        return StatusInfo(
          title: 'Cancelled',
          icon: Icons.cancel_rounded,
          color: Colors.red,
        );
      default:
        return StatusInfo(
          title: 'Unknown',
          icon: Icons.help_outline_rounded,
          color: Colors.grey,
        );
    }
  }
}

class _ChartData {
  _ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}

class StatusInfo {
  final String title;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.title,
    required this.icon,
    required this.color,
  });
}
