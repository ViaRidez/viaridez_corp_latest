import 'package:dio/dio.dart';
import '../../../auth/api/secure_tokens.dart';

class DashboardService {
  static const String _baseUrl = 'https://uat.viaridez.com/api';

  final Dio _dio;

  DashboardService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptor for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  /// Fetches user information from Keycloak API
  Future<UserInfo> getUserInfo() async {
    try {
      // Get keycloakUserId using the dedicated function
      final keycloakId = await getKeycloakUserId();

      print('Keycloak ID: $keycloakId');

      if (keycloakId == null || keycloakId.isEmpty) {
        throw Exception('Keycloak user ID not found in secure storage');
      }

      final response = await _dio.get('/keycloak/$keycloakId');

      if (response.statusCode == 200) {
        return UserInfo.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Refreshes user information
  Future<UserInfo> refreshUserInfo() async {
    return await getUserInfo();
  }
}

/// User information model
class UserInfo {
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String phonenumber;
  final String address;

  UserInfo({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phonenumber,
    required this.address,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phonenumber': phonenumber,
      'address': address,
    };
  }

  /// Get full name
  String get fullName {
    if (firstname.isEmpty && lastname.isEmpty) {
      return username;
    }
    return '$firstname $lastname'.trim();
  }

  /// Get display name (priority: full name > username)
  String get displayName {
    final name = fullName;
    return name.isNotEmpty ? name : username;
  }

  /// Get initials for avatar
  String get initials {
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      return '${firstname[0]}${lastname[0]}'.toUpperCase();
    } else if (firstname.isNotEmpty) {
      return firstname[0].toUpperCase();
    } else if (lastname.isNotEmpty) {
      return lastname[0].toUpperCase();
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }
}
