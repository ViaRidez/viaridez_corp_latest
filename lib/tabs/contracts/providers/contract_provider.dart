import 'package:flutter/material.dart';
import '../api/contract_service.dart';
import '../models/contract_model.dart';

enum ContractStatus { idle, loading, success, error }

class ContractProvider with ChangeNotifier {
  final ContractService _contractService = ContractService();

  // State variables
  ContractModel? _contract;
  ContractStatus _status = ContractStatus.idle;
  String? _errorMessage;
  bool _hasContract = false;

  // Getters
  ContractModel? get contract => _contract;
  ContractStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasContract => _hasContract;
  bool get isLoading => _status == ContractStatus.loading;
  bool get hasError => _status == ContractStatus.error;
  bool get hasData => _status == ContractStatus.success && _contract != null;

  /// Check if contract exists for client
  Future<void> checkContractExists(String clientName) async {
    _setStatus(ContractStatus.loading);

    try {
      _hasContract = await _contractService.hasContract(clientName);
      if (_hasContract) {
        _setStatus(ContractStatus.success);
      } else {
        _setError('No contract found for $clientName');
      }
    } catch (e) {
      _setError('Error checking contract: $e');
    }
  }

  /// Fetch contract PDF data
  Future<void> fetchContract(String clientName) async {
    _setStatus(ContractStatus.loading);

    try {
      final pdfData = await _contractService.getClientContract(clientName);

      if (pdfData != null && pdfData.isNotEmpty) {
        _contract = ContractModel(
          clientName: clientName,
          pdfData: pdfData,
          fileSize: pdfData.length,
          fetchedAt: DateTime.now(),
        );

        _hasContract = true;
        _setStatus(ContractStatus.success);

        print('Contract loaded successfully: ${_contract!.fileSizeFormatted}');
      } else {
        _setError('Contract data is empty');
      }
    } catch (e) {
      _setError('Failed to load contract: $e');
    }
  }

  /// Get contract file size without downloading full content
  Future<int> getContractSize(String clientName) async {
    try {
      return await _contractService.getContractSize(clientName);
    } catch (e) {
      return 0;
    }
  }

  /// Clear contract data
  void clearContract() {
    _contract = null;
    _hasContract = false;
    _status = ContractStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh contract data
  Future<void> refresh(String clientName) async {
    await fetchContract(clientName);
  }

  void _setStatus(ContractStatus status) {
    _status = status;
    if (status != ContractStatus.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = ContractStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _contractService.dispose();
    super.dispose();
  }
}
