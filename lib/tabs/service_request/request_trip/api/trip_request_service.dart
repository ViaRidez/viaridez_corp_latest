import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/journey_model.dart';

enum TripAddResult { success, error, invalidData }

class B2bTripPlanningService {
  late final Dio _dio;

  B2bTripPlanningService() {
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

  // Method to create a new trip with passenger IDs (JSON)
  Future<TripAddResult> requestTrip(
      Map<String, dynamic> tripData, List<String> passengerIds) async {
    try {
      // Add passenger IDs to trip data
      final requestData = Map<String, dynamic>.from(tripData);
      requestData['passengerIds'] = passengerIds;

      // Print the request data for debugging
      print('=== TRIP REQUEST DEBUG ===');
      print('Endpoint: ${_dio.options.baseUrl}/journey/requesttt');
      print('Request Data:');
      requestData.forEach((key, value) {
        if (key == 'journeyStartTime' || key == 'journeyEndTime') {
          print('  $key: $value (DateTime format for Java LocalDateTime)');
        } else if (key == 'shiftStartTime') {
          print('  $key: $value (Time format HH:mm:ss)');
        } else {
          print('  $key: $value');
        }
      });
      print('Passenger IDs: $passengerIds');
      print('========================');

      // Send JSON request
      final response = await _dio.post(
        '/journey/requesttt',
        data: requestData,
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.plain, // Handle plain text response
        ),
      );

      // Print response information
      print('=== TRIP REQUEST RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Headers: ${response.headers}');
      print('============================');

      // Handle response based on status code
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return TripAddResult.success;
      } else if (response.statusCode == 400) {
        return TripAddResult.invalidData;
      } else {
        print('=== TRIP REQUEST ERROR ===');
        print('Unexpected status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        print('=========================');
        return TripAddResult.error;
      }
    } on DioException catch (e) {
      print('=== TRIP REQUEST DIO EXCEPTION ===');
      print('Exception type: ${e.type}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error message: ${e.message}');
      print('=================================');

      if (e.response?.statusCode == 400) {
        return TripAddResult.invalidData;
      }
      return TripAddResult.error;
    } catch (e) {
      print('=== TRIP REQUEST GENERAL EXCEPTION ===');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('=====================================');
      return TripAddResult.error;
    }
  }

  // Method to fetch journey statuses by client name
  Future<List<JourneyModel>> getJourneyStatuses(String clientName) async {
    try {
      print('=== JOURNEY STATUS REQUEST DEBUG ===');
      print('Endpoint: ${_dio.options.baseUrl}/journey/statuss');
      print('Client Name: $clientName');
      print('===================================');

      final response = await _dio.get(
        '/journey/statuss',
        queryParameters: {
          'clientName': clientName,
        },
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      print('=== JOURNEY STATUS RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');
      print('==============================');

      if (response.statusCode == 200 && response.data != null) {
        // ✅ API returns { "status": 200, "data": [...] } — unwrap the list
        final responseBody = response.data as Map<String, dynamic>;

        if (responseBody['data'] is List) {
          return (responseBody['data'] as List)
              .map((json) => JourneyModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          print('Expected "data" key with List, got: ${responseBody['data'].runtimeType}');
          return [];
        }
      } else {
        print('=== JOURNEY STATUS ERROR ===');
        print('Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        print('===========================');
        throw Exception(
            'Failed to load journey statuses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== JOURNEY STATUS DIO EXCEPTION ===');
      print('Exception type: ${e.type}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error message: ${e.message}');
      print('===================================');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('=== JOURNEY STATUS GENERAL EXCEPTION ===');
      print('Exception: $e');
      print('Exception type: ${e.runtimeType}');
      print('=======================================');
      throw Exception('Error fetching journey statuses: $e');
    }
  }

  // Convenience method to get journey statuses for a specific status
  Future<List<JourneyModel>> getJourneysByStatus(
      String clientName, String? status) async {
    final allJourneys = await getJourneyStatuses(clientName);

    if (status == null || status.isEmpty || status.toLowerCase() == 'all') {
      return allJourneys;
    }

    return allJourneys
        .where((journey) =>
            journey.statusName?.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Convenience method to get journey statuses for CHT client (default)
  Future<List<JourneyModel>> getCHTJourneyStatuses() async {
    return getJourneyStatuses('CHT');
  }

  // Dispose resources
  void dispose() {
    _dio.close();
  }
}
