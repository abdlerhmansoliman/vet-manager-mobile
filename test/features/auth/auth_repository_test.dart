import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/network/api_client.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';
import 'package:vet_manager_mobile/features/auth/data/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSecureStorageService extends Mock implements ISecureStorageService {}
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late MockApiClient mockApiClient;
  late MockSecureStorageService mockStorage;
  late MockLocalAuthentication mockLocalAuth;
  late AuthRepository repository;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockStorage = MockSecureStorageService();
    mockLocalAuth = MockLocalAuthentication();

    repository = AuthRepository(
      apiClient: mockApiClient,
      storageService: mockStorage,
      localAuth: mockLocalAuth,
    );
  });

  group('AuthRepository', () {
    test('resolveTenants returns list of discovered clinic tenants', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          '/auth/resolve-tenants',
          data: {'email': 'dr.smith@example.com'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/resolve-tenants'),
          data: {
            'data': [
              {
                'id': 'tenant-1',
                'name': 'Alpha Animal Hospital',
                'slug': 'alpha',
                'status': 'active',
                'plan': 'pro',
              },
              {
                'id': 'tenant-2',
                'name': 'Beta Vet Clinic',
                'slug': 'beta',
                'status': 'active',
                'plan': 'enterprise',
              },
            ],
          },
        ),
      );

      final tenants = await repository.resolveTenants('dr.smith@example.com');

      expect(tenants.length, equals(2));
      expect(tenants[0].id, equals('tenant-1'));
      expect(tenants[0].name, equals('Alpha Animal Hospital'));
      expect(tenants[1].slug, equals('beta'));
    });

    test('login authenticates against tenant and saves token and tenant ID', () async {
      when(() => mockStorage.setAuthToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.setTenantId(any())).thenAnswer((_) async {});

      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          '/auth/login',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          data: {
            'token': 'secret-scoped-token',
            'user': {
              'id': 'user-1',
              'name': 'Dr. Emily Rose',
              'email': 'emily@alpha.com',
              'role': 'veterinarian',
              'is_active': true,
            },
            'tenant': {
              'id': 'tenant-alpha',
              'name': 'Alpha Animal Hospital',
              'slug': 'alpha',
              'status': 'active',
              'plan': 'pro',
            },
            'capabilities': ['prescribe', 'examine'],
          },
        ),
      );

      final session = await repository.login(
        email: 'emily@alpha.com',
        password: 'password123',
        tenantId: 'tenant-alpha',
      );

      expect(session.token, equals('secret-scoped-token'));
      expect(session.user.name, equals('Dr. Emily Rose'));
      expect(session.tenant.id, equals('tenant-alpha'));
      verify(() => mockStorage.setAuthToken('secret-scoped-token')).called(1);
      verify(() => mockStorage.setTenantId('tenant-alpha')).called(1);
    });

    test('logout clears secure storage session', () async {
      when(() => mockApiClient.post<void>('/auth/logout')).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/logout'),
          ));
      when(() => mockStorage.clearSession()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockStorage.clearSession()).called(1);
    });
  });
}
