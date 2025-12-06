import 'package:flutter/material.dart';
import '../model/staff_modal.dart';
import '../service/staff_service.dart';

class StaffProvider with ChangeNotifier {
  final StaffService _staffService = StaffService();

  List<StaffModel> _allStaffList = [];
  List<StaffModel> _filteredStaffList = [];
  bool _isLoading = false;
  bool _isEmpty = false;
  bool _showTable = false;
  String _searchQuery = '';
  String? _errorMessage;

  // Getters
  List<StaffModel> get allStaffList => _allStaffList;
  List<StaffModel> get filteredStaffList => _filteredStaffList;
  bool get isLoading => _isLoading;
  bool get isEmpty => _isEmpty;
  bool get showTable => _showTable;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  /// Fetch staff data by client name
  Future<void> fetchStaffByClient({
    required String clientName,
    required String authToken,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Validate inputs
      if (authToken.isEmpty || clientName.isEmpty) {
        _setEmptyState();
        return;
      }

      // Fetch data from service
      _allStaffList = await _staffService.fetchStaffByClient(
        clientName: clientName,
        authToken: authToken,
      );

      // Update filtered list and states (reset search)
      _filteredStaffList = List.from(_allStaffList);
      _searchQuery = ''; // Reset search query
      _isEmpty = _filteredStaffList.isEmpty;
      _showTable = _filteredStaffList.isNotEmpty;

      debugPrint(
          '✅ Staff data fetched successfully: ${_allStaffList.length} items');
    } catch (e) {
      _errorMessage = e.toString();
      _setEmptyState();
      debugPrint('❌ Failed to fetch staff data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search/filter staff by query
  void searchStaff(String query) {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _filteredStaffList = List.from(_allStaffList);
    } else {
      _filteredStaffList = _allStaffList.where((staff) {
        return staff.email.toLowerCase().contains(_searchQuery) ||
            staff.username.toLowerCase().contains(_searchQuery) ||
            staff.firstname.toLowerCase().contains(_searchQuery) ||
            staff.lastname.toLowerCase().contains(_searchQuery) ||
            staff.phonenumber.toLowerCase().contains(_searchQuery) ||
            staff.address.toLowerCase().contains(_searchQuery) ||
            staff.id.toString().contains(_searchQuery);
      }).toList();
    }

    _isEmpty = _filteredStaffList.isEmpty && _allStaffList.isNotEmpty;
    _showTable = _filteredStaffList.isNotEmpty && !_isLoading;

    debugPrint(
        '🔍 Search query: "$query" -> Found ${_filteredStaffList.length} results');
    notifyListeners();
  }

  /// Refresh staff data
  Future<void> refreshStaff({
    required String clientName,
    required String authToken,
  }) async {
    await fetchStaffByClient(
      clientName: clientName,
      authToken: authToken,
    );
  }

  /// Clear all data
  void clearData() {
    _allStaffList.clear();
    _filteredStaffList.clear();
    _searchQuery = '';
    _isEmpty = true;
    _showTable = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _isEmpty = false;
      _showTable = false;
    }
    notifyListeners();
  }

  void _setEmptyState() {
    _isEmpty = true;
    _showTable = false;
    _allStaffList.clear();
    _filteredStaffList.clear();
  }
}
