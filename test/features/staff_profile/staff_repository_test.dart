import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/core/network/api_client.dart';
import 'package:vet_manager_mobile/features/staff_profile/data/repositories/staff_repository_impl.dart';
import 'package:vet_manager_mobile/features/staff_profile/domain/entities/staff_entity.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late StaffRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = StaffRepositoryImpl(apiClient: mockApiClient);
  });

  final sampleStaffJson = <String, dynamic>{
    'id': 'user-123',
    'name': 'Dr. Anna Stone',
    'email': 'anna@clinic.com',
    'role': 'doctor',
    'role_label': 'Doctor / Veterinarian',
    'phone': '+1 555-0199',
    'is_active': true,
    'profile': {
      'id': 'prof-123',
      'job_title': 'Lead Clinician',
      'specialty': 'Equine Medicine',
      'license_number': 'VET-77112',
      'dea_number': 'XD-112233',
      'date_of_birth': '1985-04-12',
      'bio': 'Passionate about equine health.',
      'is_available': true,
    },
    'active_cases_count': 3,
    'capabilities': {
      'can_manage_staff': false,
      'can_witness_controlled_substances': true,
      'can_access_owner_dashboard': false,
      'can_prescribe_medication': true,
      'can_perform_surgery': true,
      'can_manage_billing': false,
      'is_doctor': true,
    },
    'created_at': '2026-01-15T08:00:00Z',
  };

  group('StaffRepositoryImpl', () {
    test('getStaffMembers fetches list and maps to StaffEntity models', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>(
            '/staff',
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: {
              'data': [sampleStaffJson],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/staff'),
          ));

      final result = await repository.getStaffMembers(role: 'doctor', isActive: true);

      expect(result.length, 1);
      final staff = result.first;
      expect(staff.id, 'user-123');
      expect(staff.name, 'Dr. Anna Stone');
      expect(staff.role, StaffRole.doctor);
      expect(staff.capabilities.canPrescribeMedication, isTrue);
      expect(staff.capabilities.canManageStaff, isFalse);
      expect(staff.profile?.jobTitle, 'Lead Clinician');
      expect(staff.profile?.licenseNumber, 'VET-77112');
      expect(staff.isAvailable, isTrue);
    });

    test('getStaffMember fetches individual practitioner by UUID', () async {
      when(() => mockApiClient.get<Map<String, dynamic>>('/staff/user-123'))
          .thenAnswer((_) async => Response<Map<String, dynamic>>(
                data: {'data': sampleStaffJson},
                statusCode: 200,
                requestOptions: RequestOptions(path: '/staff/user-123'),
              ));

      final staff = await repository.getStaffMember('user-123');

      expect(staff.id, 'user-123');
      expect(staff.name, 'Dr. Anna Stone');
      expect(staff.profile?.specialty, 'Equine Medicine');
    });

    test('createStaffMember sends POST /staff with validated payload', () async {
      when(() => mockApiClient.post<Map<String, dynamic>>(
            '/staff',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: {'data': sampleStaffJson},
            statusCode: 201,
            requestOptions: RequestOptions(path: '/staff'),
          ));

      final staff = await repository.createStaffMember(
        name: 'Dr. Anna Stone',
        email: 'anna@clinic.com',
        password: 'password123',
        role: StaffRole.doctor,
        phone: '+1 555-0199',
        pin: '1234',
        jobTitle: 'Lead Clinician',
        specialty: 'Equine Medicine',
        licenseNumber: 'VET-77112',
        isAvailable: true,
      );

      expect(staff.id, 'user-123');
      verify(() => mockApiClient.post<Map<String, dynamic>>(
            '/staff',
            data: {
              'name': 'Dr. Anna Stone',
              'email': 'anna@clinic.com',
              'password': 'password123',
              'role': 'doctor',
              'phone': '+1 555-0199',
              'pin': '1234',
              'job_title': 'Lead Clinician',
              'specialty': 'Equine Medicine',
              'license_number': 'VET-77112',
              'is_available': true,
            },
          )).called(1);
    });

    test('updateStaffMember sends PUT /staff/{id} with updated fields', () async {
      when(() => mockApiClient.put<Map<String, dynamic>>(
            '/staff/user-123',
            data: any<dynamic>(named: 'data'),
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: {'data': sampleStaffJson},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/staff/user-123'),
          ));

      final staff = await repository.updateStaffMember(
        userId: 'user-123',
        name: 'Dr. Anna Stone',
        email: 'anna@clinic.com',
        role: StaffRole.doctor,
        phone: '+1 555-0199',
        jobTitle: 'Chief Veterinary Officer',
      );

      expect(staff.id, 'user-123');
      verify(() => mockApiClient.put<Map<String, dynamic>>(
            '/staff/user-123',
            data: any<dynamic>(
              named: 'data',
              that: containsPair('job_title', 'Chief Veterinary Officer'),
            ),
          )).called(1);
    });

    test('updateAvailability sends PATCH /staff/{id}/availability with payload {"is_available": bool}', () async {
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/staff/user-123/availability',
            data: {'is_available': false},
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: {
              'data': {
                ...sampleStaffJson,
                'profile': {
                  ...sampleStaffJson['profile'] as Map<String, dynamic>,
                  'is_available': false,
                },
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/staff/user-123/availability'),
          ));

      final staff = await repository.updateAvailability(
        userId: 'user-123',
        isAvailable: false,
      );

      expect(staff.isAvailable, isFalse);
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/staff/user-123/availability',
            data: {'is_available': false},
          )).called(1);
    });

    test('updateStatus sends PATCH /staff/{id}/status with payload {"is_active": bool}', () async {
      when(() => mockApiClient.patch<Map<String, dynamic>>(
            '/staff/user-123/status',
            data: {'is_active': false},
          )).thenAnswer((_) async => Response<Map<String, dynamic>>(
            data: {
              'data': {
                ...sampleStaffJson,
                'is_active': false,
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/staff/user-123/status'),
          ));

      final staff = await repository.updateStatus(
        userId: 'user-123',
        isActive: false,
      );

      expect(staff.isActive, isFalse);
      verify(() => mockApiClient.patch<Map<String, dynamic>>(
            '/staff/user-123/status',
            data: {'is_active': false},
          )).called(1);
    });

    test('deleteStaffMember sends DELETE /staff/{id}', () async {
      when(() => mockApiClient.delete<dynamic>('/staff/user-123'))
          .thenAnswer((_) async => Response<dynamic>(
                statusCode: 200,
                requestOptions: RequestOptions(path: '/staff/user-123'),
              ));

      await repository.deleteStaffMember('user-123');

      verify(() => mockApiClient.delete<dynamic>('/staff/user-123')).called(1);
    });

    test('throws ValidationException on 422 HTTP response', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/staff'),
        response: Response(
          statusCode: 422,
          data: {
            'message': 'The email has already been taken.',
            'errors': {
              'email': ['The email has already been taken.'],
            },
          },
          requestOptions: RequestOptions(path: '/staff'),
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockApiClient.post<Map<String, dynamic>>(
            '/staff',
            data: any<dynamic>(named: 'data'),
          )).thenThrow(dioException);

      expect(
        () => repository.createStaffMember(
          name: 'Dr. Copy',
          email: 'copy@clinic.com',
          password: 'password123',
          role: StaffRole.doctor,
        ),
        throwsA(isA<ValidationException>().having(
          (e) => e.fieldErrors['email'],
          'email field error',
          contains('The email has already been taken.'),
        )),
      );
    });
  });
}

