import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../model/route_requested_model.dart';

enum RouteAddResult {
  success,
  error,
  connectionError,
}

class B2bRouteService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'multipart/form-data'},
    ),
  );

  B2bRouteService() {
    // Add interceptor for error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  /// Adds a new B2B route with pitstops
  Future<RouteAddResult> addRoute(
      {required String startLocation,
      required String endLocation,
      required double startLatitude,
      required double startLongitude,
      required double endLatitude,
      required double endLongitude,
      required String routeType,
      required PlatformFile pitStopExcel,
      required String requestedBy}) async {
    // Validate inputs
    if (startLocation.isEmpty || endLocation.isEmpty) {
      return RouteAddResult.error;
    }

    if (pitStopExcel.bytes == null || pitStopExcel.bytes!.isEmpty) {
      return RouteAddResult.error;
    }

    try {
      // Create form data
      final formDataMap = {
        'startLocation': startLocation,
        'endLocation': endLocation,
        'startLatitude': startLatitude.toString(),
        'startLongitude': startLongitude.toString(),
        'endLatitude': endLatitude.toString(),
        'endLongitude': endLongitude.toString(),
        'b2bRoute': 'true',
        'b2cRoute': 'false',
        'routeType': routeType,
        'requestedBy': "Client",
        'clientName': requestedBy
      };

      FormData formData = FormData.fromMap({
        ...formDataMap,
        // Add the Excel file as multipart
        'pitStopExcel': await MultipartFile.fromBytes(
          pitStopExcel.bytes!,
          filename: pitStopExcel.name,
        ),
      });

      // Send the request
      final response = await _dio.post('/route/request', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RouteAddResult.success;
      } else {
        return RouteAddResult.error;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return RouteAddResult.connectionError;
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return RouteAddResult.connectionError;
      } else if (e.type == DioExceptionType.unknown) {
        return RouteAddResult.connectionError;
      }

      return RouteAddResult.error;
    } catch (e) {
      return RouteAddResult.error;
    }
  }

  /// Fetches routes by status for a specific client
  Future<List<RouteRequestedModel>?> getRoutesByStatus({
    required String clientName,
    String? status,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'clientName': clientName,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Create a new Dio instance with application/json headers for GET request
      final getDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await getDio.get(
        '/route/by-status',
        queryParameters: queryParams,
      );

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

        return data.map((json) => RouteRequestedModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } on DioException catch (e) {
      // Handle different types of errors
      print('Error fetching routes by status: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Fetches all routes for a specific client
  Future<List<RouteRequestedModel>?> getAllRoutes({
    required String clientName,
  }) async {
    return await getRoutesByStatus(clientName: clientName);
  }

  /// Fetches requested routes for a specific client
  Future<List<RouteRequestedModel>?> getRequestedRoutes({
    required String clientName,
  }) async {
    return await getRoutesByStatus(clientName: clientName, status: 'Requested');
  }

  /// Fetches accepted routes for a specific client
  Future<List<RouteRequestedModel>?> getAcceptedRoutes({
    required String clientName,
  }) async {
    return await getRoutesByStatus(clientName: clientName, status: 'Accepted');
  }

  /// Fetches rejected routes for a specific client
  Future<List<RouteRequestedModel>?> getRejectedRoutes({
    required String clientName,
  }) async {
    return await getRoutesByStatus(clientName: clientName, status: 'Rejected');
  }
}
