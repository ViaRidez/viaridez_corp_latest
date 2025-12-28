import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../../../../utils/styles.dart';

class TeamStatsCard extends StatelessWidget {
  final Map<String, int>? dashboardCounts;

  const TeamStatsCard({
    super.key,
    this.dashboardCounts,
  });

  @override
  Widget build(BuildContext context) {
    final counts = dashboardCounts ?? {};

    return Container(
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Styles.tertiaryColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Styles.tertiaryColor.withOpacity(0.06),
            blurRadius: 48,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Styles.primaryColor.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildTeamCountIndicators(counts),
      ),
    );
  }

  Widget _buildTeamCountIndicators(Map<String, int> counts) {
    final driverCount = counts['driverCount'] ?? 0;
    final userCount = counts['userCount'] ?? 0;
    final vehicleCount = counts['vehicleCount'] ?? 0;
    final clientCount = counts['clientCount'] ?? 0;
    final partnerCount = counts['partnerCount'] ?? 0;
    final routeCount = counts['routeCount'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if it's mobile/tablet (less than 900px width)
        final isMobileOrTablet = constraints.maxWidth < 900;

        if (isMobileOrTablet) {
          // Mobile/Tablet: 2x3 grid layout
          return Column(
            children: [
              // First row
              Row(
                children: [
                  Expanded(
                    child: _buildCountItem(
                      Icons.drive_eta_rounded,
                      driverCount,
                      'Drivers',
                      Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCountItem(
                      Icons.person_rounded,
                      userCount,
                      'Users',
                      Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCountItem(
                      Icons.directions_car_rounded,
                      vehicleCount,
                      'Vehicles',
                      Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Second row
              Row(
                children: [
                  Expanded(
                    child: _buildCountItem(
                      Icons.business_rounded,
                      clientCount,
                      'Clients',
                      Colors.purple.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCountItem(
                      Icons.handshake_rounded,
                      partnerCount,
                      'Partners',
                      Colors.teal.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCountItem(
                      Icons.route_rounded,
                      routeCount,
                      'Routes',
                      Colors.indigo.shade600,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Desktop: Horizontal layout
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountItem(
                Icons.drive_eta_rounded,
                driverCount,
                'Drivers',
                Colors.blue.shade600,
              ),
              const SizedBox(width: 12),
              _buildCountItem(
                Icons.person_rounded,
                userCount,
                'Users',
                Colors.green.shade600,
              ),
              const SizedBox(width: 12),
              _buildCountItem(
                Icons.directions_car_rounded,
                vehicleCount,
                'Vehicles',
                Colors.orange.shade600,
              ),
              const SizedBox(width: 12),
              _buildCountItem(
                Icons.business_rounded,
                clientCount,
                'Clients',
                Colors.purple.shade600,
              ),
              const SizedBox(width: 12),
              _buildCountItem(
                Icons.handshake_rounded,
                partnerCount,
                'Partners',
                Colors.teal.shade600,
              ),
              const SizedBox(width: 12),
              _buildCountItem(
                Icons.route_rounded,
                routeCount,
                'Routes',
                Colors.indigo.shade600,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCountItem(
    IconData icon,
    int count,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
                Text(
                  label,
                  style: TextStyles.bodyText.copyWith(
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              '$count',
              style: TextStyles.dataValue.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Static method to fetch dashboard counts
  static Future<Map<String, int>?> fetchDashboardCounts() async {
    try {
      final dio = Dio();
      final response = await dio
          .get('${AppConfig.apiBaseUrl}/route/api/dashboard/counts');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'clientCount': data['clientCount'] ?? 0,
          'partnerCount': data['partnerCount'] ?? 0,
          'vehicleCount': data['vehicleCount'] ?? 0,
          'driverCount': data['driverCount'] ?? 0,
          'userCount': data['userCount'] ?? 0,
          'routeCount': data['routeCount'] ?? 0,
        };
      }
    } catch (e) {
      // Return null on error to handle gracefully
      return null;
    }
    return null;
  }
}
