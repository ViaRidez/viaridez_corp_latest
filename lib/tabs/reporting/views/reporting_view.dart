import 'package:flutter/material.dart';
import '../api/reporting_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../../../../utils/styles.dart';
import '../../../../auth/api/secure_tokens.dart';

class ReportingView extends StatefulWidget {
  const ReportingView({super.key});

  @override
  State<ReportingView> createState() => _ReportingViewState();
}

class _ReportingViewState extends State<ReportingView> {
  final ReportingService _reportingService = ReportingService();

  // Client name from secure storage
  String? clientName;

  // Data containers
  List<TripReportModel> tripReports = [];
  List<FleetUtilizationModel> fleetUtilization = [];

  // Status-based trip reports
  List<TripStatusReportModel> completedTrips = [];
  List<TripStatusReportModel> pendingTrips = [];
  List<TripStatusReportModel> unallocatedTrips = [];
  List<TripStatusReportModel> cancelledTrips = [];

  // Loading states
  bool isLoadingDocuments = false;
  bool isLoadingTrips = false;
  bool isLoadingFleet = false;
  bool isLoadingPerformance = false;
  bool isLoadingAttendance = false;
  bool isLoadingRoutes = false;
  bool isLoadingAssignments = false;

  // Status-based loading states
  bool isLoadingCompleted = false;
  bool isLoadingPending = false;
  bool isLoadingUnallocated = false;
  bool isLoadingCancelled = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadReports();
  }

  Future<void> _initializeAndLoadReports() async {
    // Fetch client name from secure storage
    clientName = await getClientName();

    if (clientName != null) {
      _loadAllReports();
    } else {
      _showErrorSnackBar('Client information not found. Please log in again.');
    }
  }

  @override
  void dispose() {
    _reportingService.dispose();
    super.dispose();
  }

  Future<void> _loadAllReports() async {
    // Load all reports in parallel
    await Future.wait([
      _loadTripReports(),
      _loadStatusBasedReports(),
      // _loadRouteReports(),
    ]);
  }

  Future<void> _loadTripReports() async {
    if (clientName == null) {
      _showErrorSnackBar('Client name not available');
      return;
    }

    setState(() => isLoadingTrips = true);
    try {
      final data =
          await _reportingService.getTripReports(clientName: clientName!);
      setState(() {
        tripReports = data;
        isLoadingTrips = false;
      });
    } catch (e) {
      setState(() => isLoadingTrips = false);
      _showErrorSnackBar('Failed to load trip reports: $e');
    }
  }

  Future<void> _loadStatusBasedReports() async {
    if (clientName == null) {
      _showErrorSnackBar('Client name not available');
      return;
    }

    // Load all status-based reports in parallel
    await Future.wait([
      _loadCompletedTrips(),
      _loadPendingTrips(),
      _loadUnallocatedTrips(),
      _loadCancelledTrips(),
    ]);
  }

  Future<void> _loadCompletedTrips() async {
    setState(() => isLoadingCompleted = true);
    try {
      final data = await _reportingService.getTripReportsByStatus(
        clientName: clientName!,
        status: 'completed',
      );
      setState(() {
        completedTrips = data;
        isLoadingCompleted = false;
      });
    } catch (e) {
      setState(() => isLoadingCompleted = false);
      _showErrorSnackBar('Failed to load completed trips: $e');
    }
  }

  Future<void> _loadPendingTrips() async {
    setState(() => isLoadingPending = true);
    try {
      final data = await _reportingService.getTripReportsByStatus(
        clientName: clientName!,
        status: 'pending',
      );
      setState(() {
        pendingTrips = data;
        isLoadingPending = false;
      });
    } catch (e) {
      setState(() => isLoadingPending = false);
      _showErrorSnackBar('Failed to load pending trips: $e');
    }
  }

  Future<void> _loadUnallocatedTrips() async {
    setState(() => isLoadingUnallocated = true);
    try {
      final data = await _reportingService.getTripReportsByStatus(
        clientName: clientName!,
        status: 'unallocated',
      );
      setState(() {
        unallocatedTrips = data;
        isLoadingUnallocated = false;
      });
    } catch (e) {
      setState(() => isLoadingUnallocated = false);
      _showErrorSnackBar('Failed to load unallocated trips: $e');
    }
  }

  Future<void> _loadCancelledTrips() async {
    setState(() => isLoadingCancelled = true);
    try {
      final data = await _reportingService.getTripReportsByStatus(
        clientName: clientName!,
        status: 'cancelled',
      );
      setState(() {
        cancelledTrips = data;
        isLoadingCancelled = false;
      });
    } catch (e) {
      setState(() => isLoadingCancelled = false);
      _showErrorSnackBar('Failed to load cancelled trips: $e');
    }
  }

  // Future<void> _loadRouteReports() async {
  //   setState(() => isLoadingRoutes = true);
  //   try {
  //     final data = await _reportingService.getRouteReports();
  //     setState(() {
  //       routeReports = data;
  //       isLoadingRoutes = false;
  //     });
  //   } catch (e) {
  //     setState(() => isLoadingRoutes = false);
  //     _showErrorSnackBar('Failed to load route reports: $e');
  //   }
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            // Text(
            //   'Reports Dashboard',
            //   style: TextStyles.pageTitle,
            // ),
            // const SizedBox(height: 8),
            // Text(
            //   'Comprehensive overview of all operational reports',
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Styles.textColorMed,
            //   ),
            // ),
            const SizedBox(height: 24),

            // Reports Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: _getChildAspectRatio(context),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // Trip Reports Card (Original)
                isLoadingTrips
                    ? _buildLoadingCard('Trip Reports', Icons.directions_car)
                    : TripReportCard(
                        trips: tripReports,
                        onTap: () => _showTripReportsDialog(),
                      ),

                // Completed Trips Card
                isLoadingCompleted
                    ? _buildLoadingCard('Completed Trips', Icons.check_circle)
                    : TripStatusReportCard(
                        trips: completedTrips,
                        status: 'completed',
                        onTap: () => _showCompletedTripsDialog(),
                      ),

                // Pending Trips Card
                isLoadingPending
                    ? _buildLoadingCard('Pending Trips', Icons.schedule)
                    : TripStatusReportCard(
                        trips: pendingTrips,
                        status: 'pending',
                        onTap: () => _showPendingTripsDialog(),
                      ),

                // Unallocated Trips Card
                isLoadingUnallocated
                    ? _buildLoadingCard(
                        'Unallocated Trips', Icons.assignment_late)
                    : TripStatusReportCard(
                        trips: unallocatedTrips,
                        status: 'unallocated',
                        onTap: () => _showUnallocatedTripsDialog(),
                      ),

                // Cancelled Trips Card
                isLoadingCancelled
                    ? _buildLoadingCard('Cancelled Trips', Icons.cancel)
                    : TripStatusReportCard(
                        trips: cancelledTrips,
                        status: 'cancelled',
                        onTap: () => _showCancelledTripsDialog(),
                      ),
              ],
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Styles.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Styles.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyles.cardTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularProgressIndicator(
                color: Styles.primaryColor,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 1.2;
    return 1.1;
  }

  // Placeholder dialog methods - these would contain detailed views
  void _showTripReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => TripReportDialog(trips: tripReports),
    );
  }

  void _showCompletedTripsDialog() {
    showDialog(
      context: context,
      builder: (context) => TripStatusReportDialog(
        trips: completedTrips,
        status: 'completed',
      ),
    );
  }

  void _showPendingTripsDialog() {
    showDialog(
      context: context,
      builder: (context) => TripStatusReportDialog(
        trips: pendingTrips,
        status: 'pending',
      ),
    );
  }

  void _showUnallocatedTripsDialog() {
    showDialog(
      context: context,
      builder: (context) => TripStatusReportDialog(
        trips: unallocatedTrips,
        status: 'unallocated',
      ),
    );
  }

  void _showCancelledTripsDialog() {
    showDialog(
      context: context,
      builder: (context) => TripStatusReportDialog(
        trips: cancelledTrips,
        status: 'cancelled',
      ),
    );
  }
}
