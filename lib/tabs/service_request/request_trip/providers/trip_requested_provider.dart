import 'package:flutter/material.dart';
import '../api/trip_request_service.dart';
import '../models/journey_model.dart';

class TripRequestedProvider with ChangeNotifier {
  final B2bTripPlanningService _tripService = B2bTripPlanningService();

  // State variables
  List<JourneyModel> _allTrips = [];
  List<JourneyModel> _filteredTrips = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  // Getters
  List<JourneyModel> get allTrips => _allTrips;
  List<JourneyModel> get filteredTrips => _filteredTrips;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Fetch all trips
  Future<void> fetchAllTrips({required String clientName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTrips = await _tripService.getJourneyStatuses(clientName);
      if (_allTrips.isEmpty) {
        _errorMessage = 'No trips found for $clientName';
      }
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      _allTrips = [];
      _filteredTrips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch trips by status
  Future<void> fetchTripsByStatus(String clientName, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (status.toLowerCase() == 'all') {
        _allTrips = await _tripService.getJourneyStatuses(clientName);
      } else {
        _allTrips = await _tripService.getJourneysByStatus(clientName, status);
      }
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
      _allTrips = [];
      _filteredTrips = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // Clear all filters
  void clearFilters() {
    _selectedStatus = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to the trips list
  void _applyFilters() {
    List<JourneyModel> filtered = List.from(_allTrips);

    // Apply status filter
    if (_selectedStatus.toLowerCase() != 'all') {
      filtered = filtered.where((trip) {
        final tripStatus = trip.statusName?.toLowerCase() ?? '';
        return tripStatus == _selectedStatus.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((trip) {
        return trip.id.toString().contains(query) ||
            trip.hubLocation.toLowerCase().contains(query) ||
            trip.startDestination.toLowerCase().contains(query) ||
            trip.finalDestination.toLowerCase().contains(query) ||
            trip.journeyType.toLowerCase().contains(query) ||
            trip.branchName.toLowerCase().contains(query) ||
            trip.pocClient.toLowerCase().contains(query) ||
            (trip.statusName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredTrips = filtered;
  }

  // Get trip count by status
  Map<String, int> getTripCountByStatus() {
    final Map<String, int> counts = {
      'Requested': 0,
      'Accepted': 0,
      'Rejected': 0,
    };

    for (final trip in _allTrips) {
      final status = trip.statusName ?? 'Unknown';
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }

    return counts;
  }

  // Refresh data
  Future<void> refresh({required String clientName}) async {
    await fetchAllTrips(clientName: clientName);
  }

  @override
  void dispose() {
    _tripService.dispose();
    super.dispose();
  }
}
