import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for secure local persistence (Keychain / EncryptedSharedPreferences).
abstract class ISecureStorageService {
  Future<String?> getAuthToken();
  Future<void> setAuthToken(String token);
  Future<void> clearAuthToken();

  Future<String?> getTenantId();
  Future<void> setTenantId(String tenantId);
  Future<void> clearTenantId();

  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String token);

  Future<String?> getDoctorPin();
  Future<void> setDoctorPin(String pin);

  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);

  Future<void> clearSession();
  Future<void> deleteAll();

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Production implementation of [ISecureStorageService] wrapping [FlutterSecureStorage].
class SecureStorageService implements ISecureStorageService {
  static const String _kAuthToken = 'auth_token';
  static const String _kTenantId = 'tenant_id';
  static const String _kRefreshToken = 'refresh_token';
  static const String _kDoctorPin = 'doctor_pin';
  static const String _kBiometricEnabled = 'biometric_enabled';

  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> getAuthToken() async {
    return _storage.read(key: _kAuthToken);
  }

  @override
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: _kAuthToken, value: token);
  }

  @override
  Future<void> clearAuthToken() async {
    await _storage.delete(key: _kAuthToken);
  }

  @override
  Future<String?> getTenantId() async {
    return _storage.read(key: _kTenantId);
  }

  @override
  Future<void> setTenantId(String tenantId) async {
    await _storage.write(key: _kTenantId, value: tenantId);
  }

  @override
  Future<void> clearTenantId() async {
    await _storage.delete(key: _kTenantId);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _kRefreshToken);
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _kRefreshToken, value: token);
  }

  @override
  Future<String?> getDoctorPin() async {
    return _storage.read(key: _kDoctorPin);
  }

  @override
  Future<void> setDoctorPin(String pin) async {
    await _storage.write(key: _kDoctorPin, value: pin);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _kBiometricEnabled);
    return value == 'true';
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _kBiometricEnabled, value: enabled.toString());
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _kAuthToken);
    await _storage.delete(key: _kTenantId);
    await _storage.delete(key: _kRefreshToken);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
