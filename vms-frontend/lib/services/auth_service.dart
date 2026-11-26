import 'api_client.dart';
import 'auth_session.dart';

/// Calls POST /api/auth/login and stores the returned token.
class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Throws ApiException on 400/401/network errors.
  Future<void> login(String username, String password) async {
    final response = await _client.post('/api/auth/login', {
      'username': username.trim(),
      'password': password,
    });
    final map = response as Map<String, dynamic>;
    await AuthSession.instance.save(
      map['token'] as String,
      (map['expiresIn'] as num).toInt(),
    );
  }

  Future<void> logout() => AuthSession.instance.clear();
}

final authService = AuthService();