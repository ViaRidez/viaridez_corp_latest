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
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<RouteModel> routes = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final routeJson = data[i] as Map<String, dynamic>;
            final route = RouteModel.fromJson(routeJson);
            routes.add(route);
          } catch (e) {
            // Skip this route and continue with others
            continue;
          }
        }

        return routes;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Failed to fetch routes: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          throw Exception('No routes found for client: $clientName');
        }
        throw Exception('Server error ($statusCode). Please try again later.');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
