import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app/config.dart';
import 'api_exception.dart';
import 'auth_session.dart';

/// Lightweight, reusable HTTP client for the Spring Boot backend.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
    Duration? timeout,
  })  : baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), ''),
        _httpClient = httpClient ?? http.Client(),
        timeout = timeout ?? const Duration(seconds: 10);

  Map<String, String> get _headers {
    final token = AuthSession.instance.token;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) =>
      _send(path, () => _httpClient.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(path,
      () => _httpClient.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(path,
      () => _httpClient.put(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(path, () => _httpClient.delete(_uri(path), headers: _headers));

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _send(String path, Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      return _processResponse(path, response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException catch (e) {
      throw ApiException.unreachable(e);
    } on http.ClientException catch (e) {
      throw ApiException.unreachable(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.unreachable(e);
    }
  }

  dynamic _processResponse(String path, http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.trim();

    dynamic decoded;
    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = null;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    // Expired or invalid token on a protected call: drop the session so the
    // router sends the user back to the login screen.
    if (statusCode == 401 && !path.startsWith('/api/auth/')) {
      AuthSession.instance.clear();
    }

    if (decoded is Map<String, dynamic>) {
      throw ApiException.fromJson(statusCode, decoded);
    }

    throw ApiException(
      message: 'Server returned HTTP $statusCode: ${response.reasonPhrase ?? "Error"}',
      statusCode: statusCode,
    );
  }

  void close() {
    _httpClient.close();
  }
}