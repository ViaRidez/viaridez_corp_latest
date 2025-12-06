import 'package:flutter/material.dart';
import '../api/route_request_service.dart';
import '../model/route_requested_model.dart';

enum RouteRequestedStatus { idle, loading, success, error }

class RouteRequestedProvider with ChangeNotifier {
  final B2bRouteService _routeService = B2bRouteService();

  // State management
  RouteRequestedStatus _status = RouteRequestedStatus.idle;
  RouteRequestedStatus get status => _status;

  bool get isLoading => _status == RouteRequestedStatus.loading;
  bool get hasError => _status == RouteRequestedStatus.error;
  bool get hasData => _status == RouteRequestedStatus.success;

  // Data
  List<RouteRequestedModel> _allRoutes = [];
  List<RouteRequestedModel> _filteredRoutes = [];
  String? _errorMessage;

  List<RouteRequestedModel> get allRoutes => _allRoutes;
  List<RouteRequestedModel> get filteredRoutes => _filteredRoutes;
  String? get errorMessage => _errorMessage;

  // Filters
  String _selectedStatus = 'All';
  String _searchQuery = '';

  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Available status options
  final List<String> statusOptions = [
    'All',
    'Requested',
    'Accepted',
    'Rejected'
  ];

  void _setStatus(RouteRequestedStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(RouteRequestedStatus.error);
  }

  // Set status filter
  void setStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to the routes
  void _applyFilters() {
    _filteredRoutes = _allRoutes.where((route) {
      // Status filter
      bool statusMatch = _selectedStatus == 'All' ||
          route.statusName.toLowerCase() == _selectedStatus.toLowerCase();

      // Search query filter
      bool searchMatch = _searchQuery.isEmpty ||
          route.startLocation
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          route.endLocation
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          route.id.toString().contains(_searchQuery) ||
          route.routeType.toLowerCase().contains(_searchQuery.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();

    // Sort by creation date (newest first)
    _filteredRoutes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Fetch all routes
  Future<void> fetchAllRoutes({required String clientName}) async {
    _setStatus(RouteRequestedStatus.loading);

    try {
      final routes = await _routeService.getAllRoutes(clientName: clientName);

      if (routes != null) {
        _allRoutes = routes;
        _applyFilters();
        _setStatus(RouteRequestedStatus.success);
      } else {
        _setError('Failed to fetch routes');
      }
    } catch (e) {
      _setError('Error fetching routes: $e');
    }
  }

  // Fetch routes by specific status
  Future<void> fetchRoutesByStatus(String status,
      {required String clientName}) async {
    _setStatus(RouteRequestedStatus.loading);

    try {
      List<RouteRequestedModel>? routes;

      switch (status.toLowerCase()) {
        case 'requested':
          routes =
              await _routeService.getRequestedRoutes(clientName: clientName);
          break;
        case 'accepted':
          routes =
              await _routeService.getAcceptedRoutes(clientName: clientName);
          break;
        case 'rejected':
          routes =
              await _routeService.getRejectedRoutes(clientName: clientName);
          break;
        default:
          routes = await _routeService.getAllRoutes(clientName: clientName);
      }

      if (routes != null) {
        _allRoutes = routes;
        _applyFilters();
        _setStatus(RouteRequestedStatus.success);
      } else {
        _setError('Failed to fetch routes');
      }
    } catch (e) {
      _setError('Error fetching routes: $e');
    }
  }

  // Refresh routes
  Future<void> refreshRoutes({required String clientName}) async {
    if (_selectedStatus == 'All') {
      await fetchAllRoutes(clientName: clientName);
    } else {
      await fetchRoutesByStatus(_selectedStatus, clientName: clientName);
    }
  }

  // Clear filters
  void clearFilters() {
    _selectedStatus = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Get route count by status
  Map<String, int> getRouteCountByStatus() {
    final Map<String, int> counts = {
      'All': _allRoutes.length,
      'Requested': 0,
      'Accepted': 0,
      'Rejected': 0,
    };

    for (var route in _allRoutes) {
      final status = route.statusName;
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }

    return counts;
  }

  // Get total distance for accepted routes
  double getTotalAcceptedDistance() {
    return _allRoutes
        .where((route) => route.statusName.toLowerCase() == 'accepted')
        .fold(0.0, (sum, route) => sum + route.totalDistanceKm);
  }

  // Get route by ID
  RouteRequestedModel? getRouteById(int id) {
    try {
      return _allRoutes.firstWhere((route) => route.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
