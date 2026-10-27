/// Centralized Environment Configuration for VetManager Mobile.
///
/// Values can be provided at build/run time via:
/// `flutter run --dart-define-from-file=.env`
/// or individually via:
/// `flutter run --dart-define=API_BASE_URL=...`
class AppEnv {
  const AppEnv._();

  /// Primary REST API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.3.2:8000/api/v1',
  );

  /// Application Runtime Environment (development, staging, production)
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Cloudflare R2 Diagnostics Media Endpoint
  static const String r2StorageEndpoint = String.fromEnvironment(
    'R2_STORAGE_ENDPOINT',
    defaultValue: 'https://storage.vetmanager.app',
  );

  /// Optional default tenant ID for fast development/mock testing
  static const String defaultTenantId = String.fromEnvironment(
    'DEFAULT_TENANT_ID',
    defaultValue: '',
  );

  /// Helper getters for environment branching
  static bool get isDevelopment => appEnv == 'development';
  static bool get isStaging => appEnv == 'staging';
  static bool get isProduction => appEnv == 'production';
}
