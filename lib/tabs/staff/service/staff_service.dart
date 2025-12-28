import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../model/staff_modal.dart';

class StaffService {
  late final Dio _dio;

  StaffService({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrlNoApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (log) => print('🌐 API: $log'),
      ),
    );
  }

  /// Fetch staff list filtered by clientName, requires a valid authToken
  Future<List<StaffModel>> fetchStaffByClient({
    required String clientName,
    required String authToken,
  }) async {
    if (authToken.isEmpty) {
      throw Exception('Authentication token is missing.');
    }

    if (clientName.isEmpty) {
      throw Exception('Client name is required.');
    }

    try {
      final response = await _dio.get(
        '/api/by-client',
        queryParameters: {'clientName': clientName},
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );

      print('✅ Staff API Response - Status: ${response.statusCode}');
      print('📊 Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data is List) {
        final staffList = (response.data as List)
            .map((item) => StaffModel.fromJson(item))
            .toList();

        print('📋 Parsed ${staffList.length} staff members successfully');
        return staffList;
      } else {
        throw Exception(
            'Invalid response format from API. Expected List, got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type}');
      print('📄 Response: ${e.response?.data}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception(
              'Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final errorMessage = e.response?.data?.toString() ?? 'Unknown error';
          throw Exception('Server error ($statusCode): $errorMessage');
        case DioExceptionType.cancel:
          throw Exception('Request was cancelled.');
        case DioExceptionType.connectionError:
          throw Exception('No internet connection available.');
        default:
          throw Exception('Failed to load staff: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
