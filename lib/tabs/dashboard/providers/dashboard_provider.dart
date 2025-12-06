import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../reporting/models/models.dart';
import '../../reporting/api/reporting_service.dart';
import '../../../auth/api/secure_tokens.dart';

class DashboardProvider extends ChangeNotifier {
  final ReportingService _reportingService = ReportingService();

  // Client name from secure storage
  String? _clientName;

  List<TripReportModel> _tripReports = [];
  List<FleetUtilizationModel> _fleetData = [];

  // Status-based trip reports
  List<TripStatusReportModel> _completedTrips = [];
  List<TripStatusReportModel> _pendingTrips = [];
  List<TripStatusReportModel> _unallocatedTrips = [];
  List<TripStatusReportModel> _cancelledTrips = [];

  Map<String, int>? _dashboardCounts;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TripReportModel> get tripReports => _tripReports;
  List<FleetUtilizationModel> get fleetVehicles => _fleetData;

  // Status-based trip reports getters
  List<TripStatusReportModel> get completedTrips => _completedTrips;
  List<TripStatusReportModel> get pendingTrips => _pendingTrips;
  List<TripStatusReportModel> get unallocatedTrips => _unallocatedTrips;
  List<TripStatusReportModel> get cancelledTrips => _cancelledTrips;

  Map<String, int>? get dashboardCounts => _dashboardCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get clientName => _clientName;

  // Helper method to fetch dashboard counts
  Future<Map<String, int>?> _fetchDashboardCounts() async {
    final dio = Dio();
    try {
      final response = await dio
          .get('https://uat.viaridez.com/api/route/api/dashboard/counts');

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

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch client name from secure storage
      _clientName = await getClientName();

      if (_clientName == null) {
        _errorMessage = 'Client information not found. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load all data in parallel
      final results = await Future.wait([
        _reportingService.getTripReports(clientName: _clientName!),
        _fetchDashboardCounts(),
        _reportingService.getTripReportsByStatus(
            clientName: _clientName!, status: 'completed'),
        _reportingService.getTripReportsByStatus(
            clientName: _clientName!, status: 'pending'),
        _reportingService.getTripReportsByStatus(
            clientName: _clientName!, status: 'unallocated'),
        _reportingService.getTripReportsByStatus(
            clientName: _clientName!, status: 'cancelled'),
      ]);

      _tripReports = results[0] as List<TripReportModel>;
      _dashboardCounts = results[1] as Map<String, int>?;
      _completedTrips = results[2] as List<TripStatusReportModel>;
      _pendingTrips = results[3] as List<TripStatusReportModel>;
      _unallocatedTrips = results[4] as List<TripStatusReportModel>;
      _cancelledTrips = results[5] as List<TripStatusReportModel>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  @override
  void dispose() {
    _reportingService.dispose();

    // Note: WorkshopService doesn't have a dispose method in the current implementation
    super.dispose();
  }
}
