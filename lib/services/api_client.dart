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

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
    Duration? timeout,
  })  : baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/+$'), ''),
        _httpClient = httpClient ?? http.Client(),
        timeout = timeout ?? const Duration(seconds: 10);

  /// Performs an HTTP GET request to the specified path (e.g. '/api/vehicles').
  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(timeout);

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

    // Success responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    // Backend error responses
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

