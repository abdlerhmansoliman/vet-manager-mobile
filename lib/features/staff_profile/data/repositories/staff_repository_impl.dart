import 'package:dio/dio.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/error_interceptor.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';

/// Concrete implementation of [IStaffRepository] communicating with Laravel 11 API endpoints.
class StaffRepositoryImpl implements IStaffRepository {
  final ApiClient _apiClient;

  StaffRepositoryImpl({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<StaffEntity>> getStaffMembers({
    String? role,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive ? 1 : 0;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/staff',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final dataList = response.data?['data'] as List<dynamic>? ?? [];
      return dataList
          .map((item) => StaffEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to retrieve staff directory: $e');
    }
  }

  @override
  Future<StaffEntity> getStaffMember(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/staff/$userId');
      final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
      if (data == null) {
        throw const NotFoundException(message: 'Staff member not found.');
      }
      return StaffEntity.fromJson(data);
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to retrieve staff member: $e');
    }
  }

  @override
  Future<StaffEntity> createStaffMember({
    required String name,
    required String email,
    required String password,
    required StaffRole role,
    String? phone,
    String? pin,
    String? jobTitle,
    String? specialty,
    String? licenseNumber,
    String? deaNumber,
    String? bio,
    String? dateOfBirth,
    bool isAvailable = true,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role.value,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (pin != null && pin.trim().isNotEmpty) 'pin': pin.trim(),
        if (jobTitle != null && jobTitle.trim().isNotEmpty)
          'job_title': jobTitle.trim(),
        if (specialty != null && specialty.trim().isNotEmpty)
          'specialty': specialty.trim(),
        if (licenseNumber != null && licenseNumber.trim().isNotEmpty)
          'license_number': licenseNumber.trim(),
        if (deaNumber != null && deaNumber.trim().isNotEmpty)
          'dea_number': deaNumber.trim(),
        if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
        if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
          'date_of_birth': dateOfBirth.trim(),
        'is_available': isAvailable,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/staff',
        data: payload,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
      if (data == null) {
        throw const UnknownException(message: 'Invalid response from server.');
      }
      return StaffEntity.fromJson(data);
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to create staff member: $e');
    }
  }

  @override
  Future<StaffEntity> updateStaffMember({
    required String userId,
    required String name,
    required String email,
    required StaffRole role,
    String? password,
    String? phone,
    String? pin,
    String? jobTitle,
    String? specialty,
    String? licenseNumber,
    String? deaNumber,
    String? bio,
    String? dateOfBirth,
    bool? isAvailable,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': role.value,
        if (password != null && password.isNotEmpty) 'password': password,
        if (phone != null) 'phone': phone.trim().isEmpty ? null : phone.trim(),
        if (pin != null && pin.isNotEmpty) 'pin': pin.trim(),
        if (jobTitle != null)
          'job_title': jobTitle.trim().isEmpty ? null : jobTitle.trim(),
        if (specialty != null)
          'specialty': specialty.trim().isEmpty ? null : specialty.trim(),
        if (licenseNumber != null)
          'license_number':
              licenseNumber.trim().isEmpty ? null : licenseNumber.trim(),
        if (deaNumber != null)
          'dea_number': deaNumber.trim().isEmpty ? null : deaNumber.trim(),
        if (bio != null) 'bio': bio.trim().isEmpty ? null : bio.trim(),
        if (dateOfBirth != null)
          'date_of_birth':
              dateOfBirth.trim().isEmpty ? null : dateOfBirth.trim(),
        if (isAvailable != null) 'is_available': isAvailable,
      };

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/staff/$userId',
        data: payload,
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
      if (data == null) {
        throw const UnknownException(message: 'Invalid response from server.');
      }
      return StaffEntity.fromJson(data);
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to update staff member: $e');
    }
  }

  @override
  Future<StaffEntity> updateAvailability({
    required String userId,
    required bool isAvailable,
  }) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/staff/$userId/availability',
        data: {'is_available': isAvailable},
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
      if (data == null) {
        throw const UnknownException(message: 'Invalid response from server.');
      }
      return StaffEntity.fromJson(data);
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to update doctor availability: $e');
    }
  }

  @override
  Future<StaffEntity> updateStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/staff/$userId/status',
        data: {'is_active': isActive},
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? response.data;
      if (data == null) {
        throw const UnknownException(message: 'Invalid response from server.');
      }
      return StaffEntity.fromJson(data);
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to update staff status: $e');
    }
  }

  @override
  Future<void> deleteStaffMember(String userId) async {
    try {
      await _apiClient.delete<dynamic>('/staff/$userId');
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(message: 'Failed to delete staff member: $e');
    }
  }
}

