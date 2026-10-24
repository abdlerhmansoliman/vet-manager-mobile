import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(mockStorage);
  });

  group('SecureStorageService', () {
    test('getAuthToken returns token from storage', () async {
      when(() => mockStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => 'sample_jwt_token');

      final token = await service.getAuthToken();

      expect(token, equals('sample_jwt_token'));
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('setAuthToken writes token to storage', () async {
      when(() => mockStorage.write(key: 'auth_token', value: 'sample_jwt_token'))
          .thenAnswer((_) async {});

      await service.setAuthToken('sample_jwt_token');

      verify(() => mockStorage.write(key: 'auth_token', value: 'sample_jwt_token')).called(1);
    });

    test('getTenantId and setTenantId manage tenant identifier', () async {
      when(() => mockStorage.read(key: 'tenant_id'))
          .thenAnswer((_) async => 'alpha-vet');
      when(() => mockStorage.write(key: 'tenant_id', value: 'alpha-vet'))
          .thenAnswer((_) async {});

      await service.setTenantId('alpha-vet');
      final tenantId = await service.getTenantId();

      expect(tenantId, equals('alpha-vet'));
      verify(() => mockStorage.write(key: 'tenant_id', value: 'alpha-vet')).called(1);
      verify(() => mockStorage.read(key: 'tenant_id')).called(1);
    });

    test('clearSession deletes token, tenant, and refresh_token', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await service.clearSession();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'tenant_id')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });

    test('isBiometricEnabled parses boolean correctly', () async {
      when(() => mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'true');

      final enabled = await service.isBiometricEnabled();
      expect(enabled, isTrue);

      when(() => mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'false');
      expect(await service.isBiometricEnabled(), isFalse);

      when(() => mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => null);
      expect(await service.isBiometricEnabled(), isFalse);
    });
  });
}
