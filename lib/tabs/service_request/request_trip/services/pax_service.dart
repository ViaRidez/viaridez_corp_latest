import 'package:dio/dio.dart';
import 'pax_model.dart';

class PaxService {
  static const String baseUrl = 'https://uat.viaridez.com/api';
  final Dio _dio;

  PaxService() : _dio = Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Get passengers by client name
  /// GET: https://uat.viaridez.com/api/client?clientName={clientName}
  Future<List<PaxModel>> getPassengersByClient(String clientName) async {
    try {
      if (clientName.trim().isEmpty) {
        throw Exception('Client name cannot be empty');
      }

      final response = await _dio.get(
        '/by-client',
        queryParameters: {'clientName': clientName.trim()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<PaxModel> passengers = [];

        for (int i = 0; i < data.length; i++) {
          try {
            final passengerJson = data[i] as Map<String, dynamic>;
            final passenger = PaxModel.fromJson(passengerJson);
            passengers.add(passenger);
          } catch (e) {
            // Skip this passenger and continue with others
            continue;
          }
        }

        return passengers;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              'Failed to fetch passengers for client: ${response.statusCode}',
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
          throw Exception('No passengers found for client: $clientName');
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
