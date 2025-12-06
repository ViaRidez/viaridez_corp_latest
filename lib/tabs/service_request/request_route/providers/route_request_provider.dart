import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../api/route_request_service.dart';

class RouteRequestProvider with ChangeNotifier {
  // Controllers for start and end destinations
  final TextEditingController startNameController = TextEditingController();
  final TextEditingController startLatController = TextEditingController();
  final TextEditingController startLngController = TextEditingController();

  final TextEditingController endNameController = TextEditingController();
  final TextEditingController endLatController = TextEditingController();
  final TextEditingController endLngController = TextEditingController();

  // Excel file for pitstops
  PlatformFile? pitstopsExcelFile;
  final TextEditingController pitstopsFileController = TextEditingController();

  // For route direction selection
  String routeType = 'outbound';

  // Service instance
  final B2bRouteService _routeService = B2bRouteService();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Routes list (for when we need to refresh after adding)
  List<dynamic> _routes = [];
  List<dynamic> get routes => _routes;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setRouteType(String type) {
    routeType = type;
    notifyListeners();
  }

  // Fetch routes method (placeholder - implement based on your API)
  Future<void> fetchRoutes() async {
    try {
      setLoading(true);
      // TODO: Implement actual API call to fetch routes
      // For now, just clear the list as a placeholder
      _routes = [];
      notifyListeners();
    } catch (e) {
      // Handle error
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Method to pick Excel file for pitstops
  Future<void> pickExcelFile() async {
    try {
      setLoading(true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        withData: true, // Important for getting file bytes
      );

      if (result != null) {
        pitstopsExcelFile = result.files.first;
        pitstopsFileController.text = pitstopsExcelFile!.name;
        notifyListeners();
      }
    } catch (e) {
      //debugprint('Error picking file: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Clear the selected Excel file
  void clearExcelFile() {
    pitstopsExcelFile = null;
    pitstopsFileController.clear();
    notifyListeners();
  }

  // Submit the route to the API
  Future<RouteAddResult> submitRoute({required clientName}) async {
    if (pitstopsExcelFile == null) {
      return RouteAddResult.error;
    }

    try {
      setLoading(true);

      final result = await _routeService.addRoute(
          startLocation: startNameController.text,
          endLocation: endNameController.text,
          startLatitude: double.parse(startLatController.text),
          startLongitude: double.parse(startLngController.text),
          endLatitude: double.parse(endLatController.text),
          endLongitude: double.parse(endLngController.text),
          routeType: routeType,
          pitStopExcel: pitstopsExcelFile!,
          requestedBy: clientName);

      return result;
    } catch (e) {
      //debugprint('Error submitting route: $e');
      return RouteAddResult.error;
    } finally {
      setLoading(false);
    }
  }

  // Reset all form fields
  void resetForm() {
    startNameController.clear();
    startLatController.clear();
    startLngController.clear();
    endNameController.clear();
    endLatController.clear();
    endLngController.clear();
    pitstopsFileController.clear();
    pitstopsExcelFile = null;
    routeType = 'outbound';
    notifyListeners();
  }

  @override
  void dispose() {
    startNameController.dispose();
    startLatController.dispose();
    startLngController.dispose();
    endNameController.dispose();
    endLatController.dispose();
    endLngController.dispose();
    pitstopsFileController.dispose();
    super.dispose();
  }
}
