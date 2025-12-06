import 'package:dio/dio.dart';
import '../models/models.dart';

class ReportingService {
  final Dio _dio;
  static const String baseUrl = 'https://uat.viaridez.com/api';

  ReportingService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for authentication if needed
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authentication headers here if needed
        // options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  /// Get all trip reports
  /// Returns a list of TripReportModel
  Future<List<TripReportModel>> getTripReports(
      {required String clientName}) async {
    try {
      final response = await _dio.get(
        '/trip/report/trip/client',
        queryParameters: {'clientName': clientName},
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => TripReportModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch trip reports',
        );
      }
    } on DioException catch (e) {
      print('Error fetching trip reports: ${e.message}');
      rethrow;
    }
  }

  Future<List<TripStatusReportModel>> getTripReportsByStatus(
      {required String clientName, required String status}) async {
    try {
      final response = await _dio.get(
        '/trip/report/by-status',
        queryParameters: {'status': status, 'clientName': clientName},
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => TripStatusReportModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch trip reports by status',
        );
      }
    } on DioException catch (e) {
      print('Error fetching trip reports by status: ${e.message}');
      rethrow;
    }
  }

  /// Helper method to format date to YYYY-MM-DD format
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Dispose method to clean up resources
  void dispose() {
    _dio.close();
  }
}
