import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/models.dart';
import '../../../../utils/styles.dart';

class FleetUtilizationDialog extends StatefulWidget {
  final List<FleetUtilizationModel> vehicles;

  const FleetUtilizationDialog({
    super.key,
    required this.vehicles,
  });

  @override
  State<FleetUtilizationDialog> createState() => _FleetUtilizationDialogState();
}

class _FleetUtilizationDialogState extends State<FleetUtilizationDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<FleetUtilizationModel> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicles = widget.vehicles;
    _searchController.addListener(() {
      _filterVehicles(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVehicles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = widget.vehicles;
      } else {
        _filteredVehicles = widget.vehicles
            .where((vehicle) =>
                vehicle.registrationNumber
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                vehicle.brand.toLowerCase().contains(query.toLowerCase()) ||
                vehicle.model.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
                      Icons.local_shipping,
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
                          'Fleet Utilization Analytics',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Comprehensive fleet performance and utilization insights',
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
              child: _filteredVehicles.isEmpty
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Fleet Data Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fleet utilization data will appear here once vehicles are available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Fleet',
            _filteredVehicles.length.toString(),
            Icons.local_shipping,
            Colors.blue,
            subtitle: 'All vehicles',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Assigned',
            _getAssignedCount().toString(),
            Icons.assignment,
            Colors.purple,
            subtitle: 'Currently assigned',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Vehicles',
            _getActiveCount().toString(),
            Icons.check_circle,
            Colors.green,
            subtitle: 'Currently active',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'In Workshop',
            _getWorkshopCount().toString(),
            Icons.build,
            Colors.orange,
            subtitle: 'Under maintenance',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {String? subtitle}) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        // Fleet Status Distribution
        Expanded(
          flex: 2,
          child: _buildChartContainer(
            'Fleet Status Distribution',
            SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lexend',
                ),
              ),
              series: <PieSeries<MapEntry<String, int>, String>>[
                PieSeries<MapEntry<String, int>, String>(
                  dataSource: [
                    MapEntry('Assigned', _getAssignedCount()),
                    MapEntry('Active', _getActiveCount()),
                    MapEntry('Workshop', _getWorkshopCount()),
                    MapEntry('Disabled', _getDisabledCount()),
                  ],
                  xValueMapper: (MapEntry<String, int> data, _) => data.key,
                  yValueMapper: (MapEntry<String, int> data, _) => data.value,
                  pointColorMapper: (MapEntry<String, int> data, _) {
                    switch (data.key) {
                      case 'Assigned':
                        return Colors.purple;
                      case 'Active':
                        return Colors.green;
                      case 'Workshop':
                        return Colors.orange;
                      case 'Disabled':
                        return Colors.red;
                      default:
                        return Colors.grey;
                    }
                  },
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Vehicle Utilization
        Expanded(
          flex: 3,
          child: _buildChartContainer(
            'Vehicle Trip Performance',
            SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: TextStyle(fontSize: 10, fontFamily: 'Lexend'),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(fontSize: 10, fontFamily: 'Lexend'),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ColumnSeries<MapEntry<String, int>, String>>[
                ColumnSeries<MapEntry<String, int>, String>(
                  dataSource: _filteredVehicles
                      .take(8)
                      .map((vehicle) => MapEntry(
                          vehicle.registrationNumber, vehicle.totalTrips))
                      .toList(),
                  xValueMapper: (MapEntry<String, int> data, _) => data.key,
                  yValueMapper: (MapEntry<String, int> data, _) => data.value,
                  color: Styles.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
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
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildModernDataTable() {
    return Container(
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
            decoration: BoxDecoration(
              color: Styles.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart, color: Styles.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Fleet Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Styles.primaryColor,
                    fontFamily: 'Lexend',
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredVehicles.length} vehicles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by registration, brand, or model...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontFamily: 'Lexend',
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(fontFamily: 'Lexend'),
            ),
          ),

          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 72,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
              columns: [
                DataColumn(
                  label: Text(
                    'Registration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Brand/Model',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Assigned',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Trips',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Distance (km)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Avg/Trip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Workshop Days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
              rows: _filteredVehicles
                  .map((vehicle) => DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Styles.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                vehicle.registrationNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Styles.primaryColor,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${vehicle.brand} ${vehicle.model}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                Text(
                                  'Vehicle details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(_buildStatusChip(vehicle)),
                          DataCell(_buildAssignedChip(vehicle)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTripColor(vehicle.totalTrips)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${vehicle.totalTrips}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getTripColor(vehicle.totalTrips),
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              vehicle.totalDistance.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              vehicle.avgDistancePerTrip.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getWorkshopColor(vehicle.daysInWorkshop)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${vehicle.daysInWorkshop}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _getWorkshopColor(vehicle.daysInWorkshop),
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
        ],
      ),
    );
  }

  Widget _buildStatusChip(FleetUtilizationModel vehicle) {
    Color color;
    String status;

    if (!vehicle.enabled) {
      color = Colors.red;
      status = 'Disabled';
    } else if (vehicle.inWorkshop) {
      color = Colors.orange;
      status = 'Workshop';
    } else if (vehicle.assigned) {
      color = Colors.green;
      status = 'Active';
    } else {
      color = Colors.blue;
      status = 'Available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }

  Widget _buildAssignedChip(FleetUtilizationModel vehicle) {
    Color color = vehicle.assigned ? Colors.green : Colors.grey;
    String assignedText = vehicle.assigned ? 'Assigned' : 'Unassigned';
    IconData icon =
        vehicle.assigned ? Icons.check_circle : Icons.radio_button_unchecked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            assignedText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Color _getTripColor(int trips) {
    if (trips >= 100) return Colors.green;
    if (trips >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getWorkshopColor(int days) {
    if (days == 0) return Colors.green;
    if (days <= 5) return Colors.orange;
    return Colors.red;
  }

  int _getActiveCount() {
    return _filteredVehicles
        .where((vehicle) => vehicle.enabled && !vehicle.inWorkshop)
        .length;
  }

  int _getAssignedCount() {
    return _filteredVehicles.where((vehicle) => vehicle.assigned).length;
  }

  int _getWorkshopCount() {
    return _filteredVehicles.where((vehicle) => vehicle.inWorkshop).length;
  }

  int _getDisabledCount() {
    return _filteredVehicles.where((vehicle) => !vehicle.enabled).length;
  }
}
