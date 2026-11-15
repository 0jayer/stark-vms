import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app/config.dart';
import 'api_exception.dart';

/// Lightweight, reusable HTTP client for interacting with the Spring Boot backend.
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;

  ApiClient({String? baseUrl, http.Client? httpClient, Duration? timeout})
    : baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(
        RegExp(r'/+$'),
        '',
      ),
      _httpClient = httpClient ?? http.Client(),
      timeout = timeout ?? const Duration(seconds: 10);

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<dynamic> get(String path) =>
      _send(() => _httpClient.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(
    () =>
        _httpClient.post(_uri(path), headers: _headers, body: jsonEncode(body)),
  );

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(
    () =>
        _httpClient.put(_uri(path), headers: _headers, body: jsonEncode(body)),
  );

  Future<dynamic> delete(String path) =>
      _send(() => _httpClient.delete(_uri(path), headers: _headers));

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      return _processResponse(response);
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

  dynamic _processResponse(http.Response response) {
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

    // 2xx. DELETE returns 204 with no body, so decoded is null.
    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      throw ApiException.fromJson(statusCode, decoded);
    }

    throw ApiException(
      message:
          'Server returned HTTP $statusCode: ${response.reasonPhrase ?? "Error"}',
      statusCode: statusCode,
    );
  }

  void close() {
    _httpClient.close();
  }
}
