import 'package:flutter/material.dart';
import '../api/invoices_service.dart';
import '../models/invoices_model.dart';
import '../../../auth/api/secure_tokens.dart';

class InvoicesProvider with ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _clientName;

  // Filter options
  String? _selectedClient;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _paymentFilter = 'all'; // 'all', 'paid', 'pending', 'partial'
  String _searchQuery = '';

  // Getters
  List<InvoiceModel> get invoices => _filteredInvoices;
  List<InvoiceModel> get allInvoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _filteredInvoices.isNotEmpty;
  String? get clientName => _clientName;
  String? get selectedClient => _selectedClient;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String get paymentFilter => _paymentFilter;
  String get searchQuery => _searchQuery;

  // Statistics
  int get totalInvoices => _filteredInvoices.length;

  double get totalAmount {
    return _filteredInvoices.fold<double>(
        0.0, (sum, invoice) => sum + invoice.grandTotal);
  }

  double get totalPaid {
    return _filteredInvoices.fold<double>(
        0.0, (sum, invoice) => sum + invoice.amountPaid);
  }

  double get totalOutstanding {
    return _filteredInvoices.fold<double>(
        0.0, (sum, invoice) => sum + invoice.balanceAmount);
  }

  int get paidCount {
    return _filteredInvoices.where((invoice) => invoice.isPaid).length;
  }

  int get pendingCount {
    return _filteredInvoices.where((invoice) => invoice.isPending).length;
  }

  int get partiallyPaidCount {
    return _filteredInvoices.where((invoice) => invoice.isPartiallyPaid).length;
  }

  // Get unique client names
  List<String> get clientNames {
    final names =
        _invoices.map((invoice) => invoice.clientName).toSet().toList();
    names.sort();
    return names;
  }

  // Fetch all invoices
  Future<void> fetchAllInvoices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('InvoicesProvider: Fetching client invoices...');

      // Get client name from secure storage
      _clientName = await getClientName();

      if (_clientName == null || _clientName!.isEmpty) {
        throw Exception('Client name not found. Please login again.');
      }

      print('InvoicesProvider: Fetching invoices for client: $_clientName');
      _invoices = await InvoicesService.getClientInvoices();
      print('InvoicesProvider: Fetched ${_invoices.length} invoices');

      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      print('InvoicesProvider: Error fetching invoices: $e');
      _errorMessage = e.toString();
      _invoices = [];
      _filteredInvoices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh invoices
  Future<void> refreshInvoices() async {
    await fetchAllInvoices();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredInvoices = _invoices;

    // Filter by date range
    if (_filterStartDate != null && _filterEndDate != null) {
      _filteredInvoices = _filteredInvoices.where((invoice) {
        if (invoice.startDate.length < 3 || invoice.endDate.length < 3) {
          return false;
        }

        final invoiceStart = DateTime(
          invoice.startDate[0],
          invoice.startDate[1],
          invoice.startDate[2],
        );
        final invoiceEnd = DateTime(
          invoice.endDate[0],
          invoice.endDate[1],
          invoice.endDate[2],
        );

        return invoiceStart.isBefore(_filterEndDate!) &&
            invoiceEnd.isAfter(_filterStartDate!);
      }).toList();
    }

    // Filter by payment status
    if (_paymentFilter != 'all') {
      _filteredInvoices = _filteredInvoices.where((invoice) {
        switch (_paymentFilter) {
          case 'paid':
            return invoice.isPaid;
          case 'pending':
            return invoice.isPending;
          case 'partial':
            return invoice.isPartiallyPaid;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredInvoices = _filteredInvoices.where((invoice) {
        return invoice.clientName.toLowerCase().contains(query) ||
            invoice.invoiceNumber?.toLowerCase().contains(query) == true ||
            invoice.id.toString().contains(query);
      }).toList();
    }

    print(
        'InvoicesProvider: Applied filters, ${_filteredInvoices.length} invoices match');
  }

  // Set client filter
  void setClientFilter(String? clientName) {
    _selectedClient = clientName;
    _applyFilters();
    notifyListeners();
  }

  // Set date range filter
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _applyFilters();
    notifyListeners();
  }

  // Set payment filter
  void setPaymentFilter(String filter) {
    _paymentFilter = filter;
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
    _selectedClient = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _paymentFilter = 'all';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
