import 'package:flutter/material.dart';
import '../models/models.dart';

class TripStatusReportCard extends StatelessWidget {
  final List<TripStatusReportModel> trips;
  final String status;
  final VoidCallback? onTap;

  const TripStatusReportCard({
    super.key,
    required this.trips,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalTrips = trips.length;
    final todayTrips = trips.where((trip) => trip.isToday).length;

    // Calculate average passenger utilization
    final totalCapacity =
        trips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers);
    final totalPresent =
        trips.fold<int>(0, (sum, trip) => sum + trip.presentPassengers);
    final utilizationRate =
        totalCapacity > 0 ? (totalPresent / totalCapacity) : 0.0;

    // Get status-specific styling
    final statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusInfo.color.withOpacity(0.2),
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
              // Header with status-specific design
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
                              statusInfo.color.withOpacity(0.1),
                              statusInfo.color.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          statusInfo.icon,
                          color: statusInfo.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${statusInfo.title} Trips',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Lexend',
                            ),
                          ),
                          Text(
                            '$totalTrips Total • $todayTrips Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Status indicator with count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusInfo.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo.icon,
                          color: statusInfo.color,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          totalTrips.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusInfo.color,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
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
                        totalTrips.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: statusInfo.color,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      Text(
                        statusInfo.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${(utilizationRate * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        Text(
                          'Utilization',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        todayTrips.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Trip metrics breakdown
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
                      'Trip Metrics',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricRow(
                      'Total Passengers',
                      totalPresent,
                      totalCapacity,
                      Icons.people_rounded,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'No Shows',
                      trips.fold<int>(
                          0, (sum, trip) => sum + trip.noShowPassengers),
                      totalCapacity,
                      Icons.person_off_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'With Drivers',
                      trips.where((trip) => trip.driverName.isNotEmpty).length,
                      totalTrips,
                      Icons.drive_eta_rounded,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'With Vehicles',
                      trips
                          .where((trip) => trip.vehicleNumber.isNotEmpty)
                          .length,
                      totalTrips,
                      Icons.directions_car_rounded,
                      Colors.purple,
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

  Widget _buildMetricRow(
    String title,
    int value,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? value / total : 0.0;

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
              fontFamily: 'Lexend',
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
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ],
    );
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
