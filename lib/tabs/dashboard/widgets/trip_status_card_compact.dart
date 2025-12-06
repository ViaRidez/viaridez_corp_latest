import 'package:flutter/material.dart';
import '../../../../utils/styles.dart';
import '../../reporting/models/models.dart';

class TripStatusCardCompact extends StatelessWidget {
  final List<TripStatusReportModel> trips;
  final String status;
  final VoidCallback? onTap;

  const TripStatusCardCompact({
    super.key,
    required this.trips,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    final totalTrips = trips.length;
    final todayTrips = trips.where((trip) => trip.isToday).length;

    // Calculate passenger metrics
    final totalCapacity =
        trips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers);
    final totalPresent =
        trips.fold<int>(0, (sum, trip) => sum + trip.presentPassengers);
    final utilizationRate =
        totalCapacity > 0 ? (totalPresent / totalCapacity) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Styles.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Styles.tertiaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Styles.tertiaryColor.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: statusInfo.color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusInfo.color.withOpacity(0.15),
                          statusInfo.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      statusInfo.icon,
                      color: statusInfo.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${statusInfo.title} Trips',
                          style: TextStyles.cardTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$todayTrips today',
                          style: TextStyles.hintText.copyWith(
                            fontSize: 11,
                            color: statusInfo.color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status count badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      totalTrips.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusInfo.color,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        totalTrips.toString(),
                        style: TextStyles.pageTitle.copyWith(
                          fontSize: 24,
                          color: statusInfo.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        statusInfo.title,
                        style: TextStyles.dataLabel.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  // Utilization indicator
                  if (totalTrips > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                value: utilizationRate,
                                strokeWidth: 3,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getUtilizationColor(utilizationRate * 100),
                                ),
                              ),
                            ),
                            Text(
                              '${(utilizationRate * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Utilization',
                          style: TextStyles.hintText.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar for today vs total
              // if (totalTrips > 0) ...[
              //   Row(
              //     children: [
              //       Expanded(
              //         child: LinearProgressIndicator(
              //           value: todayTrips / totalTrips,
              //           backgroundColor: Colors.grey.shade200,
              //           valueColor:
              //               AlwaysStoppedAnimation<Color>(statusInfo.color),
              //           minHeight: 4,
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Text(
              //         '$todayTrips/$totalTrips',
              //         style: TextStyle(
              //           fontSize: 10,
              //           color: Colors.grey.shade600,
              //           fontFamily: 'Lexend',
              //         ),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      ),
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

  Color _getUtilizationColor(double utilization) {
    if (utilization >= 90) return Colors.green;
    if (utilization >= 70) return Colors.blue;
    if (utilization >= 50) return Colors.orange;
    return Colors.red;
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
