import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/trip_model.dart';

class TripService {
  static final Dio _dio = Dio();

  static Future<List<TripModel>> getClientTrips({
    required String clientName,
    String? status,
  }) async {
    try {
      String url = '${AppConfig.apiBaseUrl}/trip/trips/client/$clientName';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      } else {
        url += '?status=';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Handle response as Map with data field or direct List
        List<dynamic> data;

        if (response.data is Map<String, dynamic>) {
          // API returns { "status": 200, "data": [...], ... }
          final mapData = response.data as Map<String, dynamic>;
          data = mapData['data'] as List<dynamic>? ?? [];
        } else if (response.data is List) {
          // API returns direct list
          data = response.data as List<dynamic>;
        } else {
          return [];
        }

        if (data.isEmpty) {
          return [];
        }

        return data.map((json) {
          try {
            return TripModel.fromJson(json);
          } catch (e) {
            // print('Error parsing trip: $json');
            // print('Parse error: $e');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load trips: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<TripModel>> getUnallocatedTrips(String clientName) async {
    return getClientTrips(clientName: clientName, status: 'unallocated');
  }

  static Future<List<TripModel>> getCompletedTrips(String clientName) async {
    return getClientTrips(clientName: clientName, status: 'completed');
  }

  static Future<List<TripModel>> getOngoingTrips(String clientName) async {
    return getClientTrips(clientName: clientName, status: 'ongoing');
  }

  static Future<List<TripModel>> getPendingTrips(String clientName) async {
    return getClientTrips(clientName: clientName, status: 'pending');
  }

  static Future<List<TripModel>> getCancelledTrips(String clientName) async {
    return getClientTrips(clientName: clientName, status: 'cancel');
  }

  static Future<List<TripModel>> getAllTrips(String clientName) async {
    return getClientTrips(clientName: clientName);
  }
}
