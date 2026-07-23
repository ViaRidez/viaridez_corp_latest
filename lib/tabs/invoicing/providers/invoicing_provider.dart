import 'package:flutter/material.dart';
import '../api/invoicing_service.dart';
import '../models/invoicing_model.dart';
import '../../../auth/api/secure_tokens.dart';

class InvoicingProvider extends ChangeNotifier {
  final InvoicingService _invoicingService = InvoicingService();

  // ── Generate state ────────────────────────────────────────────────────────
  InvoicingModel? _invoiceData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _clientName;

  // ── Conflict state ────────────────────────────────────────────────────────
  /// True when the API rejected the request because an invoice already exists
  /// for the requested date range.
  bool _invoiceAlreadyExists = false;

  // ── Save state ────────────────────────────────────────────────────────────
  SavedInvoiceModel? _savedInvoice;
  bool _isSaving = false;
  String? _saveErrorMessage;

  // ── Getters: generate ─────────────────────────────────────────────────────
  InvoicingModel? get invoiceData => _invoiceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get clientName => _clientName;
  bool get hasError => _errorMessage != null && !_invoiceAlreadyExists;
  bool get hasData => _invoiceData != null;
  bool get invoiceAlreadyExists => _invoiceAlreadyExists;

  // ── Getters: save ─────────────────────────────────────────────────────────
  SavedInvoiceModel? get savedInvoice => _savedInvoice;
  bool get isSaving => _isSaving;
  String? get saveErrorMessage => _saveErrorMessage;
  bool get hasSaveError => _saveErrorMessage != null;
  bool get hasSavedInvoice => _savedInvoice != null;

  // ── Error helpers ─────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSaveError() {
    _saveErrorMessage = null;
    notifyListeners();
  }

  // ── Client name ───────────────────────────────────────────────────────────
  Future<void> loadClientName() async {
    try {
      final name = await getClientName();
      _clientName = name ?? 'Unknown Client';
    } catch (_) {
      _clientName = 'Unknown Client';
    }
    notifyListeners();
  }

  // ── Generate (preview) ────────────────────────────────────────────────────
  Future<void> generateInvoice({
    String? clientName,
    required String startDate,
    required String endDate,
  }) async {
    _setLoading(true);
    _clearError();

    // Reset derived state so the UI reflects a fresh attempt.
    _invoiceAlreadyExists = false;
    _savedInvoice = null;
    _saveErrorMessage = null;

    try {
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
    } on InvoiceAlreadyExistsException catch (e) {
      // Surface as a distinct flag so the UI can render a tailored warning.
      _invoiceAlreadyExists = true;
      _errorMessage = e.message;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // ── Save (persist) ────────────────────────────────────────────────────────

  /// Calls generate-and-save using the currently displayed invoice parameters.
  /// [startDate] and [endDate] must be in yyyy-MM-dd format.
  Future<void> saveInvoice({
    required String startDate,
    required String endDate,
  }) async {
    if (_isSaving) return; // guard against double-tap

    _setSaving(true);
    _saveErrorMessage = null;
    notifyListeners();

    try {
      final effectiveClientName = _clientName ??
          _invoiceData?.clientName ??
          await getClientName() ??
          'Unknown Client';

      final saved = await _invoicingService.saveInvoice(
        clientName: effectiveClientName,
        startDate: startDate,
        endDate: endDate,
      );

      _savedInvoice = saved;
      _setSaving(false);
    } on InvoiceAlreadyExistsException catch (e) {
      // A conflict on save means the invoice was already persisted previously.
      _invoiceAlreadyExists = true;
      _saveErrorMessage = e.message;
      _setSaving(false);
    } catch (e) {
      _saveErrorMessage = e.toString();
      _setSaving(false);
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> refreshInvoice() async {
    if (_invoiceData == null) return;
    await generateInvoice(
      clientName: _clientName ?? _invoiceData!.clientName,
      startDate: _invoiceData!.formattedStartDate,
      endDate: _invoiceData!.formattedEndDate,
    );
  }

  // ── Clear all ─────────────────────────────────────────────────────────────
  void clearData() {
    _invoiceData = null;
    _savedInvoice = null;
    _errorMessage = null;
    _saveErrorMessage = null;
    _invoiceAlreadyExists = false;
    notifyListeners();
  }

  // ── Computed helpers ──────────────────────────────────────────────────────
  TripSummary? getTripSummaryByType(String tripType) {
    return _invoiceData?.tripSummaries
        .where((s) => s.tripType == tripType)
        .firstOrNull;
  }

  int get totalTripsCount =>
      _invoiceData?.tripSummaries
          .fold<int>(0, (sum, s) => sum + s.count) ??
          0;

  String get formattedGrandTotal =>
      _invoiceData?.grandTotal.toStringAsFixed(3) ?? '0.000';

  // ── Private setters ───────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSaving(bool v) {
    _isSaving = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}