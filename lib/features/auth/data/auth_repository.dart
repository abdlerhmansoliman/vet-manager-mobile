import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error_interceptor.dart';
import '../../../core/network/tenant_interceptor.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/auth_user.dart';
import '../domain/models/clinic_tenant.dart';

abstract class IAuthRepository {
  Future<List<ClinicTenant>> resolveTenants(String email);
  Future<AuthSession> login({
    required String email,
    required String password,
    required String tenantId,
    String? deviceName,
  });
  Future<void> logout();
  Future<AuthUser?> getCurrentUser();
  Future<bool> hasActiveSession();

  Future<bool> isBiometricsAvailable();
  Future<bool> authenticateWithBiometrics({String reason});
  Future<bool> isBiometricUnlockEnabled();
  Future<void> setBiometricUnlockEnabled(bool enabled);
}

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final ISecureStorageService _storageService;
  final LocalAuthentication _localAuth;

  AuthRepository({
    ApiClient? apiClient,
    ISecureStorageService? storageService,
    LocalAuthentication? localAuth,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService(),
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<List<ClinicTenant>> resolveTenants(String email) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/resolve-tenants',
        data: {'email': email.trim().toLowerCase()},
      );

      final dataList = response.data?['data'] as List<dynamic>? ?? [];
      return dataList
          .map((item) => ClinicTenant.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to resolve clinic tenants: $e');
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required String tenantId,
    String? deviceName,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'device_name': deviceName ?? 'VetManager Mobile Client',
        },
        options: Options(
          headers: {
            TenantInterceptor.headerTenantId: tenantId,
          },
        ),
      );

      final sessionData = response.data!;
      final session = AuthSession.fromJson(sessionData);

      // Persist auth tokens and active tenant in hardware-backed storage
      await _storageService.setAuthToken(session.token);
      await _storageService.setTenantId(session.tenant.id);

      return session;
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<void>('/auth/logout');
    } catch (_) {
      // Swallowed on network failure so local logout still completes
    } finally {
      await _storageService.clearSession();
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null || token.isEmpty) return null;

      final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
      final data = response.data?['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return AuthUser.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    final token = await _storageService.getAuthToken();
    final tenantId = await _storageService.getTenantId();
    return token != null && token.isNotEmpty && tenantId != null && tenantId.isNotEmpty;
  }

  @override
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to unlock VetManager clinical workspace',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBiometricUnlockEnabled() {
    return _storageService.isBiometricEnabled();
  }

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) {
    return _storageService.setBiometricEnabled(enabled);
  }
}
