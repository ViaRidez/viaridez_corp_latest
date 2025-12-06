import 'package:flutter/material.dart';
import '../models/models.dart';

class FleetUtilizationCard extends StatelessWidget {
  final List<FleetUtilizationModel> vehicles;
  final VoidCallback? onTap;

  const FleetUtilizationCard({
    super.key,
    required this.vehicles,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeVehicles = vehicles
        .where((vehicle) => vehicle.enabled && !vehicle.inWorkshop)
        .length;
    final totalVehicles = vehicles.length;
    final utilizationRate =
        totalVehicles > 0 ? (activeVehicles / totalVehicles) : 0.0;

    // Vehicle status categorization
    final activeCount = activeVehicles;
    final inWorkshopCount = vehicles.where((v) => v.inWorkshop).length;
    final disabledCount =
        vehicles.where((v) => !v.enabled && !v.inWorkshop).length;
    final availableCount = vehicles
        .where((v) => v.enabled && !v.inWorkshop && v.status == 'Available')
        .length;
    final inUseCount = vehicles
        .where((v) => v.enabled && !v.inWorkshop && v.status == 'In Use')
        .length;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with compact design
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.withOpacity(0.1),
                              Colors.indigo.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: Colors.indigo.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fleet Utilization',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '$totalVehicles Total Vehicles',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Circular progress indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: utilizationRate,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            utilizationRate >= 0.8
                                ? Colors.green
                                : utilizationRate >= 0.6
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '${(utilizationRate * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main metrics row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$activeCount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                      Text(
                        'Active Vehicles',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalVehicles',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Total Fleet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Fleet status breakdown with visual indicators
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fleet Status Distribution',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFleetStatusRow(
                      'In Use',
                      inUseCount,
                      totalVehicles,
                      Icons.play_arrow_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildFleetStatusRow(
                      'Available',
                      availableCount,
                      totalVehicles,
                      Icons.check_circle_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildFleetStatusRow(
                      'In Workshop',
                      inWorkshopCount,
                      totalVehicles,
                      Icons.build_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildFleetStatusRow(
                      'Disabled',
                      disabledCount,
                      totalVehicles,
                      Icons.block_rounded,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFleetStatusRow(
    String title,
    int count,
    int totalCount,
    IconData icon,
    Color color,
  ) {
    final percentage = totalCount > 0 ? count / totalCount : 0.0;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
