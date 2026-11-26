import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the JWT for the current session. Persisted so a page refresh keeps you
/// signed in. The password is never stored; only the token and its expiry.
class AuthSession extends ChangeNotifier {
  static final AuthSession instance = AuthSession._();
  AuthSession._();

  static const _tokenKey = 'auth_token';
  static const _expiryKey = 'auth_expiry_ms';

  String? _token;
  int? _expiryMs;

  String? get token => isAuthenticated ? _token : null;

  bool get isAuthenticated =>
      _token != null &&
      _expiryMs != null &&
      DateTime.now().millisecondsSinceEpoch < _expiryMs!;

  /// Call once at startup, before the router is used.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _expiryMs = prefs.getInt(_expiryKey);
    if (!isAuthenticated) {
      await clear();
    }
  }

  Future<void> save(String token, int expiresInSeconds) async {
    _token = token;
    _expiryMs = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setInt(_expiryKey, _expiryMs!);
    notifyListeners();
  }

  Future<void> clear() async {
    final had = _token != null;
    _token = null;
    _expiryMs = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiryKey);
    if (had) notifyListeners();
  }
}