import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

const String tokensKey = 'tokens';
const String clientNameKey = 'clientName';

/// Save tokens and clientName securely in FlutterSecureStorage.
/// Stores all tokens as a JSON string under 'tokens',
/// and saves 'clientName' separately for easy access.
Future<void> saveTokens(Map<String, dynamic> tokenData) async {
  try {
    final String jsonTokens = jsonEncode(tokenData);
    await secureStorage.write(key: tokensKey, value: jsonTokens);

    if (tokenData.containsKey('clientName')) {
      final clientName = tokenData['clientName'];
      if (clientName != null) {
        await secureStorage.write(
            key: clientNameKey, value: clientName.toString());
      }
    }
    // Optional: Add logging or feedback for success
  } catch (e) {
    // Optional: Handle error, e.g. log or report
  }
}

/// Retrieves all tokens stored under 'tokens' key.
/// Returns a Map<String, String?> or empty map if no tokens found.
Future<Map<String, String?>> getTokens() async {
  try {
    final String? jsonTokens = await secureStorage.read(key: tokensKey);
    if (jsonTokens != null && jsonTokens.isNotEmpty) {
      final Map<String, dynamic> decoded = jsonDecode(jsonTokens);
      // Convert all values to strings, handling nulls properly
      return decoded.map((key, value) => MapEntry(key, value?.toString()));
    }
    return {};
  } catch (e) {
    // Handle JSON decode errors gracefully
    print('Error retrieving tokens: $e');
    return {};
  }
}

/// Retrieves clientName from secure storage separately.
/// Returns null if not found.
Future<String?> getClientName() async {
  return await secureStorage.read(key: clientNameKey);
}

Future<String?> getKeycloakUserId() async {
  try {
    // Get all tokens and extract keycloakUserId from them
    final tokens = await getTokens();
    return tokens['keycloakUserId'];
  } catch (e) {
    print('Error retrieving keycloak user ID: $e');
    return null;
  }
}

/// Deletes tokens and clientName from secure storage.
Future<void> deleteTokens() async {
  await secureStorage.delete(key: tokensKey);
  await secureStorage.delete(key: clientNameKey);
  // Optional: Add logging or feedback for success
}
