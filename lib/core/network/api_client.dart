import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'error_interceptor.dart';
import 'idempotency_interceptor.dart';
import 'tenant_interceptor.dart';

/// Central HTTP Client for VetManager Mobile Application.
///
/// Pre-configured with:
/// - Base URL configuration
/// - 15-second connect/receive timeouts
/// - [TenantInterceptor] for automatic tenant & auth header injection
/// - [IdempotencyInterceptor] for UUID v7 idempotency protection on state changes
/// - [ErrorInterceptor] for mapping HTTP errors to domain exceptions
class ApiClient {
  static const String defaultBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.3.2:8000/api/v1');
  static const Duration defaultTimeout = Duration(seconds: 15);

  final Dio _dio;
  final ISecureStorageService _storageService;

  ApiClient({
    String baseUrl = defaultBaseUrl,
    ISecureStorageService? storageService,
    Dio? dio,
  })  : _storageService = storageService ?? SecureStorageService(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: defaultTimeout,
                receiveTimeout: defaultTimeout,
                sendTimeout: defaultTimeout,
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      TenantInterceptor(storageService: _storageService),
      IdempotencyInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Exposed [Dio] instance for repositories and data sources.
  Dio get dio => _dio;

  /// Helper GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Helper POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Helper PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Helper DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
