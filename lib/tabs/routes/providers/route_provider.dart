import 'package:flutter/material.dart';
import '../model/route_model.dart';
import '../service/route_service.dart';

class RouteTripProvider extends ChangeNotifier {
  final RouteService _service = RouteService();
  List<RouteTripReportModel> _routeTrips = [];
  bool _isLoading = false;
  String? _error;

  List<RouteTripReportModel> get routeTrips => _routeTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRouteTrips({
    required String token,
    required String clientName,
    required String startDate,
    required String endDate,
  }) async {
    _isLoading = true;
    _error = null;
    _routeTrips = []; // Clear previous data
    notifyListeners();

    try {
      _routeTrips = await _service.fetchRouteTrips(
        token: token,
        clientName: clientName,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null; // Explicitly clear error on success
    } catch (e) {
      _routeTrips = []; // Ensure list is empty on error
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method to reset state
  void reset() {
    _routeTrips = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
