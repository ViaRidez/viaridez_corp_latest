import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class that loads environment variables
/// This class provides centralized access to all environment-specific configuration
class AppConfig {
  // Safe helper to get env values without crashing
  static String _getEnv(String key, String defaultValue) {
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // API Base URLs
  static String get apiBaseUrl => _getEnv('API_BASE_URL', 'https://uat.viaridez.com/api');
  static String get apiBaseUrlNoApi => _getEnv('API_BASE_URL_NO_API', 'https://uat.viaridez.com');

  // OpenStreetMap URLs
  static String get osmNominatimBaseUrl => _getEnv('OSM_NOMINATIM_BASE_URL', 'https://nominatim.openstreetmap.org');
  static String get osmTileUrl => _getEnv('OSM_TILE_URL', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  static String get osmTileUrlWithSubdomain => _getEnv('OSM_TILE_URL_WITH_SUBDOMAIN', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');

  // Environment
  static String get environment => _getEnv('ENVIRONMENT', 'uat');
  static bool get isProduction => environment.toLowerCase() == 'production';
  static bool get isUAT => environment.toLowerCase() == 'uat';

  // Helper methods for common URL patterns
  static String getNominatimReverseUrl() {
    return '$osmNominatimBaseUrl/reverse';
  }

  static String getNominatimSearchUrl(String query) {
    return '$osmNominatimBaseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1';
  }

  static String getNominatimReverseUrlWithCoords(double lat, double lng) {
    return '$osmNominatimBaseUrl/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1';
  }

  static String getNominatimReverseUrlFull(double lat, double lng) {
    return '$osmNominatimBaseUrl/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
  }
}
