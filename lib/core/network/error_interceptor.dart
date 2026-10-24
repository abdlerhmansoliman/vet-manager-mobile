import 'package:dio/dio.dart';
import '../errors/app_exceptions.dart';

/// Interceptor that translates low-level [DioException] into strongly typed domain [AppException]s.
///
/// Handles Laravel API response structures (e.g. 422 validation errors, 401 unauthenticated,
/// 403 unauthorized tenant access, 409 idempotency / state conflict).
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final domainException = parseDioException(err);

    // Attach domain exception to DioException.error
    final modifiedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: domainException,
      message: domainException.message,
      stackTrace: err.stackTrace,
    );

    handler.next(modifiedError);
  }

  /// Converts any [DioException] into a domain [AppException].
  static AppException parseDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timed out. Please check your network and try again.',
          statusCode: err.response?.statusCode,
          details: err.message,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Unable to reach the server. Please verify network connectivity.',
          statusCode: err.response?.statusCode,
          details: err.message,
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
        );

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'The request was cancelled.',
        );

      case DioExceptionType.badResponse:
        return _parseBadResponse(err.response);

      case DioExceptionType.unknown:
      default:
        if (err.error is AppException) {
          return err.error! as AppException;
        }
        return UnknownException(
          message: err.message ?? 'An unexpected network error occurred.',
          details: err.error,
        );
    }
  }

  static AppException _parseBadResponse(Response<dynamic>? response) {
    if (response == null) {
      return const UnknownException(message: 'Received an empty error response from server.');
    }

    final statusCode = response.statusCode;
    final data = response.data;
    String? message;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String?;
    }

    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          message: message ?? 'Session expired or unauthenticated.',
          statusCode: 401,
          details: data,
        );

      case 403:
        return ForbiddenException(
          message: message ?? 'Access denied. You do not have permission for this tenant.',
          statusCode: 403,
          details: data,
        );

      case 404:
        return NotFoundException(
          message: message ?? 'Requested resource was not found.',
          statusCode: 404,
          details: data,
        );

      case 409:
        return ConflictException(
          message: message ?? 'A resource or idempotency conflict occurred.',
          statusCode: 409,
          details: data,
        );

      case 422:
        final fieldErrors = <String, List<String>>{};
        if (data is Map<String, dynamic> && data['errors'] is Map) {
          final rawErrors = data['errors'] as Map<dynamic, dynamic>;
          rawErrors.forEach((key, val) {
            if (val is List) {
              fieldErrors[key.toString()] = val.map((e) => e.toString()).toList();
            } else if (val is String) {
              fieldErrors[key.toString()] = [val];
            }
          });
        }
        return ValidationException(
          message: message ?? 'Validation failed for submitted data.',
          statusCode: 422,
          fieldErrors: fieldErrors,
          details: data,
        );

      default:
        if (statusCode != null && statusCode >= 500 && statusCode <= 599) {
          return ServerException(
            message: message ?? 'Internal server error occurred. Please try again.',
            statusCode: statusCode,
            details: data,
          );
        }

        return UnknownException(
          message: message ?? 'An HTTP error occurred ($statusCode).',
          statusCode: statusCode,
          details: data,
        );
    }
  }
}
