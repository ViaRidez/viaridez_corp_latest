const String _env = String.fromEnvironment('ENV', defaultValue: 'uat');

class AppConfig {
  AppConfig._();

  static const _configs = {
    'uat': {
      'apiBaseUrl':      'https://uat.opsrider.com/api',
      'apiBaseUrlNoApi': 'https://uat.opsrider.com',
    },
    'production': {
      'apiBaseUrl':      'https://uat.viaridez.com/api',
      'apiBaseUrlNoApi': 'https://uat.viaridez.com',
    },
  };

  // ── Third-party URLs (same in all environments) ───────────────────────────
  static const String osmNominatimBaseUrl        = 'https://nominatim.openstreetmap.org';
  static const String osmTileUrl                 = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmTileUrlWithSubdomain    = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ── Environment ───────────────────────────────────────────────────────────
  static String get environment  => _env;
  static bool   get isProduction => _env == 'production';
  static bool   get isUAT        => _env == 'uat';

  // ── API URLs ──────────────────────────────────────────────────────────────
  static String get apiBaseUrl      => _configs[_env]!['apiBaseUrl']!;
  static String get apiBaseUrlNoApi => _configs[_env]!['apiBaseUrlNoApi']!;

  // ── Nominatim helper methods ──────────────────────────────────────────────
  static String getNominatimReverseUrl() =>
      '$osmNominatimBaseUrl/reverse';

  static String getNominatimSearchUrl(String query) =>
      '$osmNominatimBaseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1';

  static String getNominatimReverseUrlWithCoords(double lat, double lng) =>
      '$osmNominatimBaseUrl/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1';

  static String getNominatimReverseUrlFull(double lat, double lng) =>
      '$osmNominatimBaseUrl/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
}