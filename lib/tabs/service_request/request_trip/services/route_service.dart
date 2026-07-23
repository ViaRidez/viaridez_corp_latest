import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/route_model.dart';

class RouteService {
  late final Dio _dio;

  RouteService() {
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

  /// Get routes by client name
  /// GET: {apiBaseUrl}/route/api/reports/route-trips?clientName={clientName}
  Future<List<RouteModel>> getRoutesByClient(String clientName) async {
    try {
      final response = await _dio.get(
        '/route/api/reports/route-trips',
        queryParameters: {'clientName': clientName},
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200 && response.data != null) {
        // ✅ Unwrap the envelope — API returns { "status": 200, "data": [...] }
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody['data'] is List) {
          return (responseBody['data'] as List)
              .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          print('Expected "data" key with List, got: ${responseBody['data']?.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
