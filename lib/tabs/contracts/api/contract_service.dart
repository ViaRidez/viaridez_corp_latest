import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:viaridez_corp/config/app_config.dart';

class ContractService {
  late final Dio _dio;

  ContractService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/pdf',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
  }

  /// Fetch client contract PDF data
  Future<Uint8List?> getClientContract(String clientName) async {
    try {
      print('=== CLIENT CONTRACT REQUEST DEBUG ===');
      print('Endpoint: ${_dio.options.baseUrl}/client/contract/$clientName');
      print('Client Name: $clientName');
      print('====================================');

      final response = await _dio.get(
        '/client/contract/$clientName',
        options: Options(
          responseType: ResponseType.bytes, // Important for PDF data
        ),
      );

      print('=== CLIENT CONTRACT RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Size: ${response.data?.length ?? 0} bytes');
      print('Response Headers: ${response.headers}');
      print('===============================');

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data);
      } else {
        print('=== CLIENT CONTRACT ERROR ===');
        print('Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        print('============================');
        throw Exception('Failed to load contract: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== CLIENT CONTRACT DIO EXCEPTION ===');
      print('Exception type: ${e.type}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error message: ${e.message}');
      print('====================================');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('=== CLIENT CONTRACT GENERAL EXCEPTION ===');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('========================================');
      throw Exception('Error fetching contract: $e');
    }
  }

  /// Check if contract exists for client
  Future<bool> hasContract(String clientName) async {
    try {
      final response = await _dio.head('/client/contract/$clientName');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Download contract and return file size
  Future<int> getContractSize(String clientName) async {
    try {
      final response = await _dio.head('/client/contract/$clientName');
      final contentLength = response.headers.value('content-length');
      return contentLength != null ? int.parse(contentLength) : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
