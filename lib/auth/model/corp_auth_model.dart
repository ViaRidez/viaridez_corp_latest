class AuthResponse {
  final bool success;
  final String? token;
  final String? error;
  final String? username;
  final String? email;
  final String? clientName;
  final String? keycloakUserId;

  AuthResponse(
      {required this.success,
      this.token,
      this.error,
      this.username,
      this.email,
      required this.clientName,
      this.keycloakUserId});
}
