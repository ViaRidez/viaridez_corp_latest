import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/dashboard_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(_getResponsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error Message
                  if (dashboardProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dashboardProvider.errorMessage!,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                          TextButton(
                            onPressed: () => dashboardProvider.refreshData(),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                  // Loading or Content
                  Expanded(
                    child: dashboardProvider.isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Loading dashboard data...',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _hasAnyData(dashboardProvider)
                            ? _buildResponsiveGrid(dashboardProvider)
                            : _buildEmptyState(dashboardProvider),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResponsiveGrid(DashboardProvider dashboardProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          // Large screens (desktop)
          crossAxisCount = 4;
          childAspectRatio = 2;
        } else if (constraints.maxWidth > 900) {
          // Medium screens (tablets in landscape)
          crossAxisCount = 3;
          childAspectRatio = 2.0;
        } else if (constraints.maxWidth > 600) {
          // Small tablets and large phones
          crossAxisCount = 2;
          childAspectRatio = 2;
        } else {
          // Mobile phones
          crossAxisCount = 1;
          childAspectRatio = 2;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Team Stats Card at the top - full width horizontal
              // Container(
              //   width: double.infinity,
              //   margin: EdgeInsets.only(bottom: _getResponsiveSpacing(context)),
              //   child: TeamStatsCard(
              //     dashboardCounts: dashboardProvider.dashboardCounts,
              //   ),
              // ),

              // Rest of the cards in grid layout
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: _getResponsiveSpacing(context),
                mainAxisSpacing: _getResponsiveSpacing(context),
                childAspectRatio: childAspectRatio,
                children: [
                  // Trip Report Card (Original)
                  TripReportCardCompact(
                    trips: dashboardProvider.tripReports,
                  ),

                  // Completed Trips Card
                  TripStatusCardCompact(
                    trips: dashboardProvider.completedTrips,
                    status: 'completed',
                  ),

                  // Pending Trips Card
                  TripStatusCardCompact(
                    trips: dashboardProvider.pendingTrips,
                    status: 'pending',
                  ),

                  // Unallocated Trips Card
                  TripStatusCardCompact(
                    trips: dashboardProvider.unallocatedTrips,
                    status: 'unallocated',
                  ),

                  // Cancelled Trips Card
                  TripStatusCardCompact(
                    trips: dashboardProvider.cancelledTrips,
                    status: 'cancelled',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 48.0; // Desktop
    } else if (screenWidth > 900) {
      return 32.0; // Tablet landscape
    } else if (screenWidth > 600) {
      return 24.0; // Tablet portrait
    } else {
      return 16.0; // Mobile
    }
  }

  double _getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) {
      return 16.0; // Desktop/tablet
    } else {
      return 12.0; // Mobile
    }
  }

  bool _hasAnyData(DashboardProvider provider) {
    return provider.tripReports.isNotEmpty ||
        provider.fleetVehicles.isNotEmpty ||
        provider.completedTrips.isNotEmpty ||
        provider.pendingTrips.isNotEmpty ||
        provider.unallocatedTrips.isNotEmpty ||
        provider.cancelledTrips.isNotEmpty;
    // || provider.dashboardCounts != null;
  }

  Widget _buildEmptyState(DashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No dashboard data available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check your connection and try refreshing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.refreshData(),
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
