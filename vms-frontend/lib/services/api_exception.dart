/// Exception thrown when an API request fails, carrying backend error details
/// or a user-friendly error message if the server is unreachable.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;
  final String? timestamp;
  final Map<String, dynamic>? fieldErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.timestamp,
    this.fieldErrors,
  });

  /// Creates an [ApiException] parsed from a Spring Boot error response:
  /// `{timestamp, status, error, message, fieldErrors?}`
  factory ApiException.fromJson(int statusCode, Map<String, dynamic> json) {
    Map<String, dynamic>? fieldErrors;
    if (json['fieldErrors'] is Map<String, dynamic>) {
      fieldErrors = json['fieldErrors'] as Map<String, dynamic>;
    }

    final message =
        json['message'] as String? ??
        json['error'] as String? ??
        'HTTP $statusCode request failed';

    return ApiException(
      message: message,
      statusCode: (json['status'] is int) ? json['status'] as int : statusCode,
      error: json['error'] as String?,
      timestamp: json['timestamp'] as String?,
      fieldErrors: fieldErrors,
    );
  }

  /// Field names mapped to their error messages (empty when none).
  Map<String, String> get fieldErrorStrings {
    final errors = fieldErrors;
    if (errors == null) return const {};
    return errors.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Friendly error when the server is unreachable or offline.
  factory ApiException.unreachable([dynamic _]) {
    return const ApiException(
      message: 'Unable to reach the server. Please ensure the Spring Boot backend is running and your connection is active.',
    );
  }

  /// Friendly error when a request times out.
  factory ApiException.timeout() {
    return const ApiException(
      message: 'Request timed out. The server took too long to respond. Please try again.',
    );
  }

  @override
  String toString() => message;
}
