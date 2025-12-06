import 'package:flutter/material.dart';
import 'pax_model.dart';
import 'pax_service.dart';

class PaxProvider extends ChangeNotifier {
  final PaxService _paxService = PaxService();

  // State variables
  List<PaxModel> _passengers = [];
  List<PaxModel> _filteredPassengers = [];
  List<String> _clientNames = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedClient;
  Map<String, dynamic> _statistics = {};

  // Getters
  List<PaxModel> get passengers => _passengers;
  List<PaxModel> get filteredPassengers => _filteredPassengers;
  List<String> get clientNames => _clientNames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedClient => _selectedClient;
  Map<String, dynamic> get statistics => _statistics;

  // Load passengers by client
  Future<void> loadPassengersByClient(String clientName) async {
    _setLoading(true);
    _clearError();

    try {
      _passengers = await _paxService.getPassengersByClient(clientName);
      _selectedClient = clientName;
      _applyFilters();
      await _updateStatistics();
    } catch (e) {
      _setError('Failed to load passengers for client: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update statistics based on current filtered passengers
  Future<void> _updateStatistics() async {
    try {
      final totalPassengers = _filteredPassengers.length;
      final presentPassengers =
          _filteredPassengers.where((p) => p.presentForTheTrip).length;
      final absentPassengers = totalPassengers - presentPassengers;
      final uniqueClients =
          _filteredPassengers.map((p) => p.clientName).toSet().length;
      final uniqueRoutes =
          _filteredPassengers.map((p) => p.routeDescription).toSet().length;

      _statistics = {
        'total': totalPassengers,
        'present': presentPassengers,
        'absent': absentPassengers,
        'clients': uniqueClients,
        'routes': uniqueRoutes,
        'presentPercentage': totalPassengers > 0
            ? (presentPassengers / totalPassengers * 100).round()
            : 0,
      };
    } catch (e) {
      // Silently handle error for statistics update
    }
  }

  // Set search query and apply filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set selected client filter
  void setClientFilter(String? clientName) {
    _selectedClient = clientName;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedClient = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply current filters to passenger list
  void _applyFilters() {
    _filteredPassengers = _passengers.where((passenger) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fullName =
            '${passenger.firstname} ${passenger.lastname}'.toLowerCase();
        final email = passenger.email.toLowerCase();
        final phone = passenger.phonenumber.toLowerCase();
        final boardingPlace = passenger.boardingPlace.toLowerCase();

        if (!fullName.contains(query) &&
            !email.contains(query) &&
            !phone.contains(query) &&
            !boardingPlace.contains(query)) {
          return false;
        }
      }

      // Client filter
      if (_selectedClient != null && _selectedClient!.isNotEmpty) {
        if (passenger.clientName != _selectedClient) {
          return false;
        }
      }

      return true;
    }).toList();

    _updateStatistics();
  }

  // Refresh data
  Future<void> refresh() async {
    if (_selectedClient != null) {
      await loadPassengersByClient(_selectedClient!);
    }
  }

  // Get passengers by attendance status
  List<PaxModel> getPassengersByAttendance(bool isPresent) {
    return _filteredPassengers
        .where((p) => p.presentForTheTrip == isPresent)
        .toList();
  }

  // Get passengers by route
  Map<String, List<PaxModel>> getPassengersByRoute() {
    final Map<String, List<PaxModel>> routeMap = {};
    for (final passenger in _filteredPassengers) {
      final route = passenger.routeDescription;
      routeMap.putIfAbsent(route, () => []).add(passenger);
    }
    return routeMap;
  }

  // Get passengers by client
  Map<String, List<PaxModel>> getPassengersByClientMap() {
    final Map<String, List<PaxModel>> clientMap = {};
    for (final passenger in _filteredPassengers) {
      final client = passenger.clientName;
      clientMap.putIfAbsent(client, () => []).add(passenger);
    }
    return clientMap;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _paxService.dispose();
    super.dispose();
  }
}
