import 'package:flutter/material.dart';
import '../models/quotations_model.dart';
import '../api/quotations_service.dart';

class QuotationsProvider with ChangeNotifier {
  final QuotationsService _quotationsService = QuotationsService();

  // State variables
  List<Quotation> _quotations = [];
  bool _isLoading = false;
  String? _error;
  String _currentClientFilter = 'CHT'; // Default client filter

  // Getters
  List<Quotation> get quotations => _quotations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentClientFilter => _currentClientFilter;

  // Helper getters
  bool get hasData => _quotations.isNotEmpty;
  int get quotationCount => _quotations.length;

  double get totalValueAllQuotations {
    return _quotations.fold(
        0.0, (sum, quotation) => sum + quotation.totalPrice);
  }

  /// Load quotations for the current client filter
  Future<void> loadQuotations() async {
    _setLoading(true);
    _setError(null);

    try {
      final quotations =
          await _quotationsService.getQuotationsByClient(_currentClientFilter);
      _quotations = quotations;

      // Sort by creation date (newest first)
      _quotations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh quotations data
  Future<void> refreshQuotations() async {
    await loadQuotations();
  }

  /// Change client filter and reload data
  Future<void> setClientFilter(String clientName) async {
    if (_currentClientFilter != clientName) {
      _currentClientFilter = clientName;
      await loadQuotations();
    }
  }

  /// Get quotation by index
  Quotation? getQuotationByIndex(int index) {
    if (index >= 0 && index < _quotations.length) {
      return _quotations[index];
    }
    return null;
  }

  /// Search quotations by report name
  List<Quotation> searchQuotations(String query) {
    if (query.isEmpty) return _quotations;

    final lowercaseQuery = query.toLowerCase();
    return _quotations
        .where((quotation) =>
            quotation.reportName.toLowerCase().contains(lowercaseQuery) ||
            quotation.client.clientName.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Filter quotations by date range
  List<Quotation> getQuotationsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _quotations.where((quotation) {
      try {
        final quotationDate =
            DateTime.parse(quotation.createdAt.replaceAll(' ', 'T'));
        return quotationDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            quotationDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Get total routes count across all quotations
  int get totalRoutesCount {
    return _quotations.fold(0, (sum, quotation) => sum + quotation.routeCount);
  }

  /// Get average quotation value
  double get averageQuotationValue {
    if (_quotations.isEmpty) return 0.0;
    return totalValueAllQuotations / _quotations.length;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _quotationsService.dispose();
    super.dispose();
  }
}
