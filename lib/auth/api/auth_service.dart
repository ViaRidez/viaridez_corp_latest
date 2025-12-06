import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../model/corp_auth_model.dart';
import 'secure_tokens.dart';

class AuthService {
  final _logger = Logger('OptAuthService');
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://uat.viaridez.com/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<AuthResponse> optloginWithKeycloak(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '/admin-corporate-client-login',
        data: {'email': email, 'password': password},
      );
      print(response.statusCode);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data;
        print(data);

        if (!data.containsKey('token')) {
          _logger.warning('Login response missing token');
          return AuthResponse(
            success: false,
            error: 'Invalid server response',
            clientName: '',
          );
        }

        final tokens = {
          "token": data["token"]?.toString() ?? '',
          "keycloakUserId": data["keycloakUserId"]?.toString() ?? '',
          "databaseUserId": data["databaseUserId"]?.toString() ?? '',
          "email": data["email"]?.toString() ?? '',
          "userName": data["userName"]?.toString() ?? '',
          "clientName": data["clientName"]?.toString() ?? '',
          "corpUser": data['corpUser']?.toString() ?? '',
        };

        await saveTokens(tokens);

        return AuthResponse(
          success: true,
          token: data["token"].toString(),
          username: data['userName'].toString(),
          email: data['email'].toString(),
          clientName: data['clientName'].toString(),
          keycloakUserId: data['keycloakUserId'].toString(),
        );
      }

      return AuthResponse(
        success: false,
        error: 'Authentication failed',
        clientName: '',
      );
    } on DioException catch (e) {
      _logger.severe('Network error during login', e);

      // Extract actual error message from response
      String errorMessage = 'Network error occurred';

      if (e.response != null && e.response?.data != null) {
        try {
          final responseData = e.response!.data;

          // Check if response has an error field
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['error']?.toString() ??
                responseData['message']?.toString() ??
                'Authentication failed';
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        } catch (_) {
          errorMessage = 'Authentication failed';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      return AuthResponse(
        success: false,
        error: errorMessage,
        clientName: '',
      );
    } catch (e) {
      _logger.severe('Unexpected error during login', e);
      return AuthResponse(
        success: false,
        error: 'An unexpected error occurred',
        clientName: '',
      );
    }
  }
}
