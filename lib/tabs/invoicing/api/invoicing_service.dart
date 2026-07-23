import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/invoicing_model.dart';

/// Thrown when the API rejects a generate/save request because an invoice
/// for the same date range (or an overlapping period) already exists.
class InvoiceAlreadyExistsException implements Exception {
  final String message;

  const InvoiceAlreadyExistsException([
    this.message =
    'An invoice already exists for this date range or an overlapping period.',
  ]);

  @override
  String toString() => message;
}

class InvoicingService {
  final Dio _dio = Dio();

  InvoicingService() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
  }

  // ── Generate (preview only, no persistence) ───────────────────────────────

  Future<InvoicingModel> generateInvoice({
    required String clientName,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/trip/generate',
        queryParameters: {
          'clientName': clientName,
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      if (response.statusCode == 200) {
        return InvoicingModel.fromJson(response.data);
      }
      throw _badResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ── Generate + Save (persists invoice and returns invoice number) ─────────

  /// Calls /trip/generate-and-save which both computes the invoice totals
  /// and persists a record in the database.
  /// Returns a [SavedInvoiceModel] containing [invoiceNumber], [status], etc.
  Future<SavedInvoiceModel> saveInvoice({
    required String clientName,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/trip/generate-and-save',
        queryParameters: {
          'clientName': clientName,
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      if (response.statusCode == 200) {
        return SavedInvoiceModel.fromJson(response.data);
      }
      throw _badResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns true when the server message indicates an existing invoice conflict.
  /// Checked against lowercase so casing changes in the API don't matter.
  bool _isConflictMessage(String msg) {
    final lower = msg.toLowerCase();
    return lower.contains('invoice already exists') ||
        lower.contains('overlapping period');
  }

  DioException _badResponse(Response response) => DioException(
    requestOptions: response.requestOptions,
    response: response,
    message: 'Request failed with status ${response.statusCode}',
  );

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
            'Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return Exception('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final data = error.response?.data;

        // Safely extract the message field regardless of how Dio decoded it.
        final msg = switch (data) {
          Map() => data['message']?.toString() ?? 'Unknown error',
          String() => data,
          _ => 'Unknown error',
        };

        if (_isConflictMessage(msg)) {
          return InvoiceAlreadyExistsException(msg);
        }
        return Exception('Server error ($code): $msg');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      case DioExceptionType.unknown:
      default:
        return Exception('Unknown error: ${error.message}');
    }
  }
}