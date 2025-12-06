import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/auth_service.dart';
import '../api/secure_tokens.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  String? _token;
  String? _clientName;
  String? _keycloakUserId;
  String? _databaseUserId;
  final _storage = const FlutterSecureStorage();

  String _username = '';

  static const String _usernameKey = 'username';
  static const String _clientNameKey = 'clientName';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _keycloakUserIdKey = 'keycloakUserId';
  static const String _databaseUserIdKey = 'databaseUserId';

  bool _mounted = true;
  bool _hidePassword = true;
  bool get hidePassword => _hidePassword;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String get username => _username;
  String? get clientName => _clientName;
  String? get keycloakUserId => _keycloakUserId;
  String? get databaseUserId => _databaseUserId;

  /// Check if user is fully authenticated with all required data
  bool get isFullyAuthenticated =>
      _isLoggedIn &&
          _token != null &&
          _token!.isNotEmpty &&
          _clientName != null &&
          _clientName!.isNotEmpty;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (!_mounted) return;
    try {
      final storedToken = await _storage.read(key: _tokenKey);
      final storedLoginState = await _storage.read(key: _isLoggedInKey);
      final storedClientName = await _storage.read(key: _clientNameKey);
      final storedUsername = await _storage.read(key: _usernameKey);
      final storedKeycloakUserId = await _storage.read(key: _keycloakUserIdKey);
      final storedDatabaseUserId = await _storage.read(key: _databaseUserIdKey);

      if (!_mounted) return;

      // Check if we have valid stored credentials
      if (storedToken != null &&
          storedLoginState == 'true' &&
          storedClientName != null &&
          storedClientName.isNotEmpty) {
        _token = storedToken;
        _isLoggedIn = true;
        _clientName = storedClientName;
        _username = storedUsername ?? 'Unknown User';
        _keycloakUserId = storedKeycloakUserId;
        _databaseUserId = storedDatabaseUserId;

        await loadUserData();
      } else {
        // Clear any incomplete data
        await _clearStoredData();
        _isLoggedIn = false;
      }

      if (_mounted) notifyListeners();
    } catch (e) {
      if (_mounted) {
        _errorMessage = "Error initializing auth state";
        await _clearStoredData();
        _isLoggedIn = false;
        notifyListeners();
      }
    }
  }

  Future<void> _clearStoredData() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _isLoggedInKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: 'email'),
      _storage.delete(key: _clientNameKey),
      _storage.delete(key: _keycloakUserIdKey),
      _storage.delete(key: _databaseUserIdKey),
      deleteTokens(),
    ]);
  }

  Future<void> login() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _isLoggedIn = false;
      notifyListeners();

      await deleteTokens();
      await _clearStoredData();

      final result = await _authService.optloginWithKeycloak(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (result.success &&
          result.token != null &&
          result.clientName != null &&
          result.clientName!.isNotEmpty) {
        _isLoggedIn = true;
        _token = result.token;
        _username = result.username ?? 'Unknown User';
        _clientName = result.clientName;
        _keycloakUserId = result.keycloakUserId;

        print("token: ${result.token}");
        print("username: ${result.username}");
        print("email: ${result.email}");
        print("clientName: $_clientName");
        print("keycloakUserId: $_keycloakUserId");

        await Future.wait([
          _storage.write(key: _tokenKey, value: result.token),
          _storage.write(key: _isLoggedInKey, value: 'true'),
          _storage.write(key: _usernameKey, value: _username),
          _storage.write(key: 'email', value: result.email),
          _storage.write(key: _clientNameKey, value: _clientName ?? ''),
          if (result.keycloakUserId != null)
            _storage.write(key: _keycloakUserIdKey, value: result.keycloakUserId),
          saveTokens({
            "token": result.token,
            "username": _username,
            "clientName": _clientName ?? '',
            "email": result.email,
            "keycloakUserId": result.keycloakUserId ?? '',
          }),
        ]);

        clearCredentials();
      } else {
        // Use the actual error message from the backend
        _errorMessage =
            result.error ?? "Login failed. Please check your credentials.";
        _isLoggedIn = false;
        print("Login failed: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
      _isLoggedIn = false;
      print("Login exception: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Optional: Call backend logout API if uncommented in AuthService
      // if (_keycloakUserId != null) {
      //   await _authService.optlogout();
      // }

      await _clearStoredData();

      _isLoggedIn = false;
      _token = null;
      _username = '';
      _clientName = null;
      _keycloakUserId = null;
      _databaseUserId = null;
      _errorMessage = null;

      clearCredentials();
    } catch (e) {
      _errorMessage = "An error occurred during logout.";
      print("Logout error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    if (!_isLoggedIn || !_mounted) return;

    try {
      final tokens = await getTokens();
      if (_mounted) {
        _username = tokens['username'] ?? _username;
        _clientName = tokens['clientName'] ?? _clientName;
        _keycloakUserId = tokens['keycloakUserId'] ?? _keycloakUserId;
        notifyListeners();
      }
    } catch (e) {
      if (_mounted) {
        _username = 'Unknown User';
        print("Error loading user data: $e");
        notifyListeners();
      }
    }
  }

  /// Check if the current token is still valid
  Future<bool> isTokenValid() async {
    if (_token == null || _token!.isEmpty) return false;

    try {
      // You can add a token validation API call here if needed
      // For now, just check if we have the required data
      return _clientName != null && _clientName!.isNotEmpty;
    } catch (e) {
      print("Token validation error: $e");
      return false;
    }
  }

  void togglePasswordVisibility() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  void clearCredentials() {
    usernameController.clear();
    passwordController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mounted = false;
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
