import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
const String tokensKey = 'tokens';
const String clientNameKey = 'clientName';

/// Save tokens and clientName securely (WEB COMPATIBLE)
/// For web: uses browser localStorage
/// For mobile: uses FlutterSecureStorage
Future<void> saveTokens(Map<String, dynamic> tokenData) async {
  try {
    final String jsonTokens = jsonEncode(tokenData);

    if (kIsWeb) {
      // For web: use browser localStorage
      html.window.localStorage[tokensKey] = jsonTokens;
      print('✅ Tokens saved to localStorage (web)');

      if (tokenData.containsKey('clientName')) {
        final clientName = tokenData['clientName'];
        if (clientName != null) {
          html.window.localStorage[clientNameKey] = clientName.toString();
          print('✅ Client name saved: $clientName');
        }
      }
    } else {
      // For mobile: use flutter_secure_storage
      await _secureStorage.write(key: tokensKey, value: jsonTokens);
      print('✅ Tokens saved to secure storage (mobile)');

      if (tokenData.containsKey('clientName')) {
        final clientName = tokenData['clientName'];
        if (clientName != null) {
          await _secureStorage.write(
              key: clientNameKey, value: clientName.toString());
          print('✅ Client name saved: $clientName');
        }
      }
    }
  } catch (e) {
    print('❌ Error saving tokens: $e');
  }
}

/// Retrieves all tokens (WEB COMPATIBLE)
/// For web: reads from browser localStorage
/// For mobile: reads from FlutterSecureStorage
Future<Map<String, String?>> getTokens() async {
  try {
    String? jsonTokens;

    if (kIsWeb) {
      // For web: read from browser localStorage
      jsonTokens = html.window.localStorage[tokensKey];
      print('📖 Reading tokens from localStorage (web)');
    } else {
      // For mobile: read from flutter_secure_storage
      jsonTokens = await _secureStorage.read(key: tokensKey);
      print('📖 Reading tokens from secure storage (mobile)');
    }

    if (jsonTokens != null && jsonTokens.isNotEmpty) {
      final Map<String, dynamic> decoded = jsonDecode(jsonTokens);
      final result = decoded.map((key, value) => MapEntry(key, value?.toString()));
      print('✅ Found tokens: ${result.keys.toList()}');
      return result;
    }

    print('⚠️ No tokens found');
    return {};
  } catch (e) {
    print('❌ Error getting tokens: $e');
    return {};
  }
}

/// Retrieves clientName (WEB COMPATIBLE)
Future<String?> getClientName() async {
  try {
    if (kIsWeb) {
      return html.window.localStorage[clientNameKey];
    } else {
      return await _secureStorage.read(key: clientNameKey);
    }
  } catch (e) {
    print('Error retrieving client name: $e');
    return null;
  }
}

Future<String?> getKeycloakUserId() async {
  try {
    final tokens = await getTokens();
    return tokens['keycloakUserId'];
  } catch (e) {
    print('Error retrieving keycloak user ID: $e');
    return null;
  }
}

/// Deletes tokens (WEB COMPATIBLE)
/// For web: removes from browser localStorage
/// For mobile: deletes from FlutterSecureStorage
Future<void> deleteTokens() async {
  try {
    if (kIsWeb) {
      html.window.localStorage.remove(tokensKey);
      html.window.localStorage.remove(clientNameKey);
      print('🗑️ Tokens deleted from localStorage (web)');
    } else {
      await _secureStorage.delete(key: tokensKey);
      await _secureStorage.delete(key: clientNameKey);
      print('🗑️ Tokens deleted from secure storage (mobile)');
    }
  } catch (e) {
    print('❌ Error deleting tokens: $e');
  }
}
