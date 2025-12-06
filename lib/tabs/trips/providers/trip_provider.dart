import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripProvider with ChangeNotifier {
  List<TripModel> _trips = [];
  List<TripModel> _filteredTrips = [];
  bool _isLoading = false;
  String? _error;
  TripStatus? _selectedStatus;
  String _searchQuery = '';

  List<TripModel> get trips => _trips;
  List<TripModel> get filteredTrips => _filteredTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TripStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Trip counts by status
  int get unallocatedCount => _trips
      .where((trip) => trip.tripStatus?.toLowerCase() == 'unallocated')
      .length;

  int get completedCount => _trips
      .where((trip) => trip.tripStatus?.toLowerCase() == 'completed')
      .length;

  int get ongoingCount => _trips
      .where((trip) => trip.tripStatus?.toLowerCase() == 'ongoing')
      .length;

  int get pendingCount => _trips
      .where((trip) => trip.tripStatus?.toLowerCase() == 'pending')
      .length;

  int get cancelledCount => _trips
      .where((trip) =>
          trip.tripStatus?.toLowerCase() == 'cancel' ||
          trip.tripStatus?.toLowerCase() == 'cancelled')
      .length;

  Future<void> fetchTrips(String clientName, {TripStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<TripModel> fetchedTrips;

      if (status == null) {
        fetchedTrips = await TripService.getAllTrips(clientName);
      } else {
        switch (status) {
          case TripStatus.unallocated:
            fetchedTrips = await TripService.getUnallocatedTrips(clientName);
            break;
          case TripStatus.completed:
            fetchedTrips = await TripService.getCompletedTrips(clientName);
            break;
          case TripStatus.ongoing:
            fetchedTrips = await TripService.getOngoingTrips(clientName);
            break;
          case TripStatus.pending:
            fetchedTrips = await TripService.getPendingTrips(clientName);
            break;
          case TripStatus.cancel:
            fetchedTrips = await TripService.getCancelledTrips(clientName);
            break;
        }
      }

      _trips = fetchedTrips;
      // Sort by ID in descending order (newest first)
      _trips.sort((a, b) => b.id.compareTo(a.id));
      _selectedStatus = status;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByStatus(TripStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void searchTrips(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<TripModel> filtered = List.from(_trips);

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((trip) {
        final tripStatus = TripStatus.fromString(trip.tripStatus);
        return tripStatus == _selectedStatus;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((trip) {
        return trip.id.toString().contains(query) ||
            trip.hubLocation?.toLowerCase().contains(query) == true ||
            trip.tripType?.toLowerCase().contains(query) == true ||
            trip.startDestination?.toLowerCase().contains(query) == true ||
            trip.finalDestination?.toLowerCase().contains(query) == true ||
            trip.pocClient?.toLowerCase().contains(query) == true ||
            trip.driverFullName.toLowerCase().contains(query) ||
            trip.tripStatus?.toLowerCase().contains(query) == true ||
            trip.vehicleRegistrationNumber?.toLowerCase().contains(query) ==
                true ||
            trip.branchName?.toLowerCase().contains(query) == true;
      }).toList();
    }

    _filteredTrips = filtered;
  }

  void clearFilters() {
    _selectedStatus = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void refreshTrips(String clientName) {
    fetchTrips(clientName, status: _selectedStatus);
  }
}
