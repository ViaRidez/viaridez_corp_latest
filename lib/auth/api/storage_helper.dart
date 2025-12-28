import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;

/// Web-compatible storage helper
/// Uses localStorage for web, FlutterSecureStorage for mobile
class StorageHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Write a value to storage
  static Future<void> write({required String key, required String value}) async {
    try {
      if (kIsWeb) {
        html.window.localStorage[key] = value;
      } else {
        await _secureStorage.write(key: key, value: value);
      }
    } catch (e) {
      print('Error writing to storage ($key): $e');
    }
  }

  /// Read a value from storage
  static Future<String?> read({required String key}) async {
    try {
      if (kIsWeb) {
        return html.window.localStorage[key];
      } else {
        return await _secureStorage.read(key: key);
      }
    } catch (e) {
      print('Error reading from storage ($key): $e');
      return null;
    }
  }

  /// Delete a value from storage
  static Future<void> delete({required String key}) async {
    try {
      if (kIsWeb) {
        html.window.localStorage.remove(key);
      } else {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      print('Error deleting from storage ($key): $e');
    }
  }
}
