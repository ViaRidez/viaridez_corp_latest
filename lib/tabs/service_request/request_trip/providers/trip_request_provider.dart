import 'package:flutter/material.dart';

import '../api/trip_request_service.dart';
import '../models/route_model.dart';

enum TripSubmitStatus {
  initial,
  loading,
  success,
  error, idle,
}

class TripRequestProvider with ChangeNotifier {
  // Loading and Error states
  final B2bTripPlanningService _tripService = B2bTripPlanningService();
  bool _isLoading = false;
  String? _errorMessage;
  TripSubmitStatus _submitStatus = TripSubmitStatus.initial;

  // Form controllers for basic trip info
  final TextEditingController noteController = TextEditingController();
  final TextEditingController tripStartDateTimeController =
      TextEditingController();
  final TextEditingController tripEndDateTimeController =
      TextEditingController();
  final TextEditingController shiftStartTimeController =
      TextEditingController();

  // Selected values - route model instead of string
  RouteModel? _selectedRoute;

  // Passenger selection - only existing passengers
  List<String> _selectedPassengerIds = [];

  DateTime? _tripStartDateTime;
  DateTime? _tripEndDateTime;
  String? _shiftStartTime;

  // Operating days
  List<String> _operatingDays = [];
  final Map<String, String> _dayNameMapping = {
    'Mon': 'Monday',
    'Tue': 'Tuesday',
    'Wed': 'Wednesday',
    'Thu': 'Thursday',
    'Fri': 'Friday',
    'Sat': 'Saturday',
    'Sun': 'Sunday'
  };

  // Helper method to format DateTime for backend (LocalDateTime format without milliseconds)
  String? _formatDateTimeForBackend(DateTime? dateTime) {
    if (dateTime == null) return null;

    // Format as: 2025-08-07T00:30:00 (without milliseconds and timezone)
    return dateTime.toIso8601String().split('.')[0];
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TripSubmitStatus get submitStatus => _submitStatus;

  RouteModel? get selectedRoute => _selectedRoute;
  String? get selectedRouteId => _selectedRoute?.routeId.toString();
  List<String> get selectedPassengerIds => _selectedPassengerIds;
  List<String> get operatingDays => _operatingDays;
  List<String> get daysOfWeek => _dayNameMapping.keys.toList();
  List<String> get operatingDaysForBackend =>
      _operatingDays.map((day) => _dayNameMapping[day] ?? day).toList();
  DateTime? get tripStartDateTime => _tripStartDateTime;
  DateTime? get tripEndDateTime => _tripEndDateTime;
  String? get shiftStartTime => _shiftStartTime;
  // Setters
  set tripStartDateTime(DateTime? dateTime) {
    _tripStartDateTime = dateTime;
    notifyListeners();
  }

  set tripEndDateTime(DateTime? dateTime) {
    _tripEndDateTime = dateTime;
    notifyListeners();
  }

  set shiftStartTime(String? time) {
    _shiftStartTime = time;
    notifyListeners();
  }

  void setSelectedRoute(RouteModel? route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void setOperatingDays(List<String> days) {
    _operatingDays = days;
    notifyListeners();
  }

  void removeOperatingDay(String day) {
    _operatingDays.remove(day);
    notifyListeners();
  }

  void resetForm() {
    // Clear controllers
    tripStartDateTimeController.clear();
    tripEndDateTimeController.clear();
    shiftStartTimeController.clear();
    noteController.clear();

    // Reset state
    tripStartDateTime = null;
    tripEndDateTime = null;
    shiftStartTime = null;
    _selectedRoute = null;
    _selectedPassengerIds = [];
    _operatingDays = [];
    _submitStatus = TripSubmitStatus.initial; // ← critical: reset status
    notifyListeners();
  }
  // Passenger selection methods
  void togglePassengerSelection(String passengerId) {
    if (_selectedPassengerIds.contains(passengerId)) {
      _selectedPassengerIds.remove(passengerId);
    } else {
      _selectedPassengerIds.add(passengerId);
    }
    notifyListeners();
  }

  void clearSelectedPassengers() {
    _selectedPassengerIds.clear();
    notifyListeners();
  }

  // Method to submit trip data
  Future<void> submitTripData(String clientName) async {
    if (!validateForm()) {
      return;
    }

    _submitStatus = TripSubmitStatus.loading;
    _isLoading = true;
    notifyListeners();

    try {
      // Create a trip data model with all the form values
      final tripData = {
        'clientName': clientName,
        'routeId': _selectedRoute?.routeId.toString(),
        'journeyStartTime': _formatDateTimeForBackend(_tripStartDateTime),
        'journeyEndTime': _formatDateTimeForBackend(_tripEndDateTime),
        'workingDays': operatingDaysForBackend,
        'note': noteController.text,
        'shiftStartTime': shiftStartTime,
        'isB2b': true,
        'isB2c': false
      };

      // Use passenger IDs API
      final result =
          await _tripService.requestTrip(tripData, _selectedPassengerIds);

      if (result == TripAddResult.success) {
        _submitStatus = TripSubmitStatus.success;
        _isLoading = false;
        notifyListeners();
      } else if (result == TripAddResult.invalidData) {
        _submitStatus = TripSubmitStatus.error;
        _isLoading = false;
        _errorMessage = 'Invalid data provided. Please check your entries.';
        notifyListeners();
      } else {
        _submitStatus = TripSubmitStatus.error;
        _isLoading = false;
        _errorMessage = 'Failed to submit trip data. Please try again.';
        notifyListeners();
      }
    } catch (e) {
      _submitStatus = TripSubmitStatus.error;
      _isLoading = false;
      _errorMessage = 'Failed to submit trip data: $e';
      notifyListeners();
    }
  }

  // Validate all required fields
  bool validateForm() {
    // Basic validation - check if all required fields are filled
    if (_selectedRoute == null ||
        tripStartDateTimeController.text.isEmpty ||
        tripEndDateTimeController.text.isEmpty ||
        shiftStartTimeController.text.isEmpty ||
        _operatingDays.isEmpty) {
      _errorMessage = 'Please fill all required fields';
      notifyListeners();
      return false;
    }

    // Validate passenger selection
    if (_selectedPassengerIds.isEmpty) {
      _errorMessage = 'Please select at least one passenger';
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    // Clean up controllers
    noteController.dispose();
    tripStartDateTimeController.dispose();
    tripEndDateTimeController.dispose();
    shiftStartTimeController.dispose();

    super.dispose();
  }
}
