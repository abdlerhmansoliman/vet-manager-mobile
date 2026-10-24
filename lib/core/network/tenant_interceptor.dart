import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor responsible for injecting multi-tenant headers and Bearer auth credentials.
///
/// Complies with VetManager backend tenancy architecture:
/// - Injects `X-Tenant-ID` header for tenant-scoped operations.
/// - Injects `Authorization: Bearer <token>` when user is authenticated.
/// - Injects `Accept: application/json` standard header.
class TenantInterceptor extends QueuedInterceptor {
  static const String headerTenantId = 'X-Tenant-ID';
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';

  final ISecureStorageService _storageService;

  TenantInterceptor({
    required ISecureStorageService storageService,
  }) : _storageService = storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Ensure JSON response acceptance
    options.headers[headerAccept] ??= 'application/json';

    // 2. Inject Tenant ID if not already explicitly provided in the request
    if (!options.headers.containsKey(headerTenantId) ||
        options.headers[headerTenantId] == null ||
        options.headers[headerTenantId].toString().isEmpty) {
      final tenantId = await _storageService.getTenantId();
      if (tenantId != null && tenantId.trim().isNotEmpty) {
        options.headers[headerTenantId] = tenantId.trim();
      }
    }

    // 3. Inject Bearer Authentication Token if not already provided
    if (!options.headers.containsKey(headerAuthorization) ||
        options.headers[headerAuthorization] == null ||
        options.headers[headerAuthorization].toString().isEmpty) {
      final token = await _storageService.getAuthToken();
      if (token != null && token.trim().isNotEmpty) {
        options.headers[headerAuthorization] = 'Bearer ${token.trim()}';
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // Check if backend returned tenant resolution header for validation/debug
    // final resolvedTenant = response.headers.value('X-Tenant-Resolved');
    handler.next(response);
  }
}
