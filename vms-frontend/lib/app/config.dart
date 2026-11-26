/// Centralized configuration for the VMS frontend application.
///
/// The API base URL is resolved at build/run time from the environment:
/// `--dart-define=API_BASE_URL=http://your-server:8080`
/// Defaults to 'http://localhost:8080' if not provided.
class AppConfig {
  AppConfig._();

  /// The base URL for the backend Spring Boot REST API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}

