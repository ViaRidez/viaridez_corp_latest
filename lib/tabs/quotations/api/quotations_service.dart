import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/quotations_model.dart';

class QuotationsService {
  late final Dio _dio;

  QuotationsService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
  }

  /// Fetches all quotations from the API
  Future<List<Quotation>> getAllQuotations() async {
    try {
      final response = await _dio.get('/price/all');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;

        return data
            .map((quotationJson) => Quotation.fromJson(quotationJson))
            .toList();
      } else {
        throw Exception('Failed to fetch quotations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Quotations not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Forbidden access');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quotations: $e');
    }
  }

  /// Fetches quotations filtered by client name
  Future<List<Quotation>> getQuotationsByClient(String clientName) async {
    try {
      final allQuotations = await getAllQuotations();

      // Filter quotations by client name
      return allQuotations
          .where((quotation) =>
              quotation.client.clientName.toLowerCase() ==
              clientName.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch quotations for client $clientName: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
