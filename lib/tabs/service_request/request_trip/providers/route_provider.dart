import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();

  // State variables
  List<RouteModel> _routes = [];
  bool _isLoading = false;
  String? _error;
  RouteModel? _selectedRoute;

  // Getters
  List<RouteModel> get routes => _routes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RouteModel? get selectedRoute => _selectedRoute;

  // Load routes by client
  Future<void> loadRoutesByClient(String clientName) async {
    _setLoading(true);
    _clearError();

    try {
      _routes = await _routeService.getRoutesByClient(clientName);
    } catch (e) {
      _setError('Failed to load routes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Select a route
  void selectRoute(RouteModel route) {
    _selectedRoute = route;
    notifyListeners();
  }

  // Clear selected route
  void clearSelectedRoute() {
    _selectedRoute = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _routeService.dispose();
    super.dispose();
  }
}
