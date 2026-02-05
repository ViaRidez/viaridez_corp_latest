import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../model/route_model.dart';

class RouteService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  Future<List<RouteTripReportModel>> fetchRouteTrips({
    required String token,
    required String clientName,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/route/api/reports/route-trips',
        queryParameters: {
          'start': startDate,
          'end': endDate,
          'clientName': clientName,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Check if response is a Map with data field
        if (response.data is Map<String, dynamic>) {
          final mapData = response.data as Map<String, dynamic>;

          // Extract the data array from the response
          if (mapData.containsKey('data') && mapData['data'] is List) {
            final list = mapData['data'] as List;

            // Return empty list if no data (this is not an error)
            if (list.isEmpty) {
              return [];
            }

            return list
                .map((item) => RouteTripReportModel.fromJson(item))
                .toList();
          }

          // If no data field, return empty list
          return [];
        }

        // Check if response is a List directly
        if (response.data is List) {
          final list = response.data as List;

          // Return empty list if no data (this is not an error)
          if (list.isEmpty) {
            return [];
          }

          return list
              .map((item) => RouteTripReportModel.fromJson(item))
              .toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to fetch route trips: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle specific HTTP error responses
        if (e.response!.statusCode == 404) {
          throw Exception('Route trips endpoint not found');
        } else if (e.response!.statusCode == 401) {
          throw Exception('Unauthorized. Please login again');
        } else if (e.response!.statusCode == 500) {
          throw Exception('Server error. Please try again later');
        }

        // Try to extract error message from response
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }

        throw Exception('Error ${e.response!.statusCode}: ${e.message}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server took too long to respond');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }
}
