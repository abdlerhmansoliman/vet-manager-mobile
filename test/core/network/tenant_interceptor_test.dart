import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/network/tenant_interceptor.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late MockSecureStorageService mockStorage;
  late TenantInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/test'));
  });

  setUp(() {
    mockStorage = MockSecureStorageService();
    interceptor = TenantInterceptor(storageService: mockStorage);
    mockHandler = MockRequestInterceptorHandler();
  });

  group('TenantInterceptor', () {
    test('injects X-Tenant-ID and Bearer token when stored in secure storage', () async {
      when(() => mockStorage.getTenantId()).thenAnswer((_) async => 'clinic-alpha');
      when(() => mockStorage.getAuthToken()).thenAnswer((_) async => 'test-jwt-token-123');

      final options = RequestOptions(path: '/api/v1/patients');

      await interceptor.onRequest(options, mockHandler);

      expect(options.headers['X-Tenant-ID'], equals('clinic-alpha'));
      expect(options.headers['Authorization'], equals('Bearer test-jwt-token-123'));
      expect(options.headers['Accept'], equals('application/json'));
      verify(() => mockHandler.next(options)).called(1);
    });

    test('preserves explicitly provided X-Tenant-ID header without overwriting', () async {
      when(() => mockStorage.getTenantId()).thenAnswer((_) async => 'stored-clinic');
      when(() => mockStorage.getAuthToken()).thenAnswer((_) async => 'token');

      final options = RequestOptions(
        path: '/api/v1/patients',
        headers: {'X-Tenant-ID': 'custom-clinic-override'},
      );

      await interceptor.onRequest(options, mockHandler);

      expect(options.headers['X-Tenant-ID'], equals('custom-clinic-override'));
      verify(() => mockHandler.next(options)).called(1);
    });

    test('does not set X-Tenant-ID or Authorization when storage returns null', () async {
      when(() => mockStorage.getTenantId()).thenAnswer((_) async => null);
      when(() => mockStorage.getAuthToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/api/v1/public/ping');

      await interceptor.onRequest(options, mockHandler);

      expect(options.headers.containsKey('X-Tenant-ID'), isFalse);
      expect(options.headers.containsKey('Authorization'), isFalse);
      expect(options.headers['Accept'], equals('application/json'));
      verify(() => mockHandler.next(options)).called(1);
    });
  });
}
