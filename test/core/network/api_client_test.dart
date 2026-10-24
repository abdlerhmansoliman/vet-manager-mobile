import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/network/api_client.dart';
import 'package:vet_manager_mobile/core/network/error_interceptor.dart';
import 'package:vet_manager_mobile/core/network/idempotency_interceptor.dart';
import 'package:vet_manager_mobile/core/network/tenant_interceptor.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
  });

  group('ApiClient', () {
    test('initializes with default base URL, timeouts, and required interceptors', () {
      final client = ApiClient(storageService: mockStorage);

      expect(client.dio.options.baseUrl, equals(ApiClient.defaultBaseUrl));
      expect(client.dio.options.connectTimeout, equals(const Duration(seconds: 15)));
      expect(client.dio.options.receiveTimeout, equals(const Duration(seconds: 15)));
      expect(client.dio.options.headers['Accept'], equals('application/json'));
      expect(client.dio.options.headers['Content-Type'], equals('application/json'));

      final interceptorTypes = client.dio.interceptors.map((i) => i.runtimeType).toList();
      expect(interceptorTypes, contains(TenantInterceptor));
      expect(interceptorTypes, contains(IdempotencyInterceptor));
      expect(interceptorTypes, contains(ErrorInterceptor));
    });

    test('supports custom base URL override', () {
      final client = ApiClient(
        baseUrl: 'https://api.vetmanager.io/v1',
        storageService: mockStorage,
      );

      expect(client.dio.options.baseUrl, equals('https://api.vetmanager.io/v1'));
    });
  });
}
