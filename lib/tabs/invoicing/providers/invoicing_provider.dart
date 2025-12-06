import 'package:flutter/material.dart';
import '../api/invoicing_service.dart';
import '../models/invoicing_model.dart';
import '../../../auth/api/secure_tokens.dart';

class InvoicingProvider extends ChangeNotifier {
  final InvoicingService _invoicingService = InvoicingService();

  InvoicingModel? _invoiceData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _clientName;

  // Getters
  InvoicingModel? get invoiceData => _invoiceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get clientName => _clientName;
  bool get hasError => _errorMessage != null;
  bool get hasData => _invoiceData != null;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load client name from secure storage
  Future<void> loadClientName() async {
    try {
      final clientName = await getClientName();
      _clientName = clientName ?? 'Unknown Client';
      notifyListeners();
    } catch (e) {
      _clientName = 'Unknown Client';
      notifyListeners();
    }
  }

  // Generate invoice with custom parameters
  Future<void> generateInvoice({
    String? clientName,
    required String startDate,
    required String endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Use provided client name or fetch from secure storage
      final effectiveClientName = clientName ??
          _clientName ??
          await getClientName() ??
          'Unknown Client';

      final invoice = await _invoicingService.generateInvoice(
        clientName: effectiveClientName,
        startDate: startDate,
        endDate: endDate,
      );

      _invoiceData = invoice;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Refresh current invoice data
  Future<void> refreshInvoice() async {
    if (_invoiceData != null) {
      await generateInvoice(
        clientName: _clientName ?? _invoiceData!.clientName,
        startDate: _invoiceData!.formattedStartDate,
        endDate: _invoiceData!.formattedEndDate,
      );
    }
  }

  // Clear all data
  void clearData() {
    _invoiceData = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Get trip summary by type
  TripSummary? getTripSummaryByType(String tripType) {
    return _invoiceData?.tripSummaries
        .where((summary) => summary.tripType == tripType)
        .firstOrNull;
  }

  // Get total trips count
  int get totalTripsCount {
    return _invoiceData?.tripSummaries
            .fold<int>(0, (sum, summary) => sum + summary.count) ??
        0;
  }

  // Get formatted grand total
  String get formattedGrandTotal {
    return _invoiceData?.grandTotal.toStringAsFixed(3) ?? '0.000';
  }
}
