import 'package:flutter/material.dart';
import '../../../../utils/styles.dart';
import '../../reporting/models/trip_report_model.dart';

class TripReportCardCompact extends StatelessWidget {
  final List<TripReportModel> trips;
  final VoidCallback? onTap;

  const TripReportCardCompact({
    super.key,
    required this.trips,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedTrips = trips
        .where((trip) => trip.tripStatus.toLowerCase() == 'completed')
        .length;
    final totalTrips = trips.length;
    final completionRate = totalTrips > 0 ? (completedTrips / totalTrips) : 0.0;

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
            color: Styles.primaryColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                          Styles.primaryColor.withOpacity(0.1),
                          Styles.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.route_rounded,
                      color: Styles.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Trip Reports',
                      style: TextStyles.cardTitle,
                    ),
                  ),
                  // Compact circular progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 4,
                          backgroundColor:
                              Styles.tertiaryColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionRate >= 0.8
                                ? Styles.primaryColor
                                : completionRate >= 0.5
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '${(completionRate * 100).toInt()}%',
                        style: TextStyles.dataValue.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main metrics in a compact row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$completedTrips',
                            style: TextStyles.pageTitle.copyWith(
                              fontSize: 28,
                              color: Styles.primaryColor,
                            ),
                          ),
                          Text(
                            '/$totalTrips',
                            style: TextStyles.bodyText.copyWith(
                              fontSize: 18,
                              color: Styles.textColorMed,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Completed Trips',
                        style: TextStyles.dataLabel.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Trip status indicators
                  _buildMiniTripIndicators(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTripIndicators() {
    final completedTrips = trips
        .where((trip) => trip.tripStatus.toLowerCase() == 'completed')
        .length;
    final ongoingTrips = trips
        .where((trip) => trip.tripStatus.toLowerCase() == 'ongoing')
        .length;
    final cancelledTrips = trips
        .where((trip) => trip.tripStatus.toLowerCase() == 'cancelled')
        .length;
    final scheduledTrips = trips
        .where((trip) => trip.tripStatus.toLowerCase() == 'scheduled')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniIndicator(
              Icons.check_circle,
              completedTrips,
              trips.length,
              Colors.green,
            ),
            const SizedBox(width: 6),
            _buildMiniIndicator(
              Icons.play_circle_fill,
              ongoingTrips,
              trips.length,
              Colors.blue,
            ),
            const SizedBox(width: 6),
            _buildMiniIndicator(
              Icons.schedule,
              scheduledTrips,
              trips.length,
              Colors.orange,
            ),
            const SizedBox(width: 6),
            _buildMiniIndicator(
              Icons.cancel,
              cancelledTrips,
              trips.length,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'C • O • S • X',
          style: TextStyles.hintText.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniIndicator(
    IconData icon,
    int count,
    int totalCount,
    Color color,
  ) {
    final rate = totalCount > 0 ? count / totalCount : 0.0;

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withOpacity(rate > 0.1 ? 0.4 : 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(rate > 0.1 ? 0.8 : 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 14,
        color: rate > 0.1 ? color : color.withOpacity(0.6),
      ),
    );
  }
}
