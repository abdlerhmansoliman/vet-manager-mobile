import 'package:equatable/equatable.dart';

/// Base class for all domain-level exceptions in the VetManager application.
abstract class AppException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  List<Object?> get props => [message, statusCode, details];

  @override
  String toString() => '$runtimeType: $message (Status: $statusCode)';
}

/// Thrown when network connectivity is lost, request times out, or DNS fails.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection failed. Please check your internet connection.',
    super.statusCode,
    super.details,
  });
}

/// Thrown when authentication fails or access token has expired (HTTP 401).
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired or unauthorized. Please log in again.',
    super.statusCode = 401,
    super.details,
  });
}

/// Thrown when the user does not have permission or token is not scoped to tenant (HTTP 403).
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to access this clinic or resource.',
    super.statusCode = 403,
    super.details,
  });
}

/// Thrown when a requested resource is not found (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.details,
  });
}

/// Thrown when a synchronization or data conflict occurs (HTTP 409).
class ConflictException extends AppException {
  const ConflictException({
    super.message = 'A data conflict occurred. Please refresh and retry.',
    super.statusCode = 409,
    super.details,
  });
}

/// Thrown when server validation fails (HTTP 422).
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message = 'The provided input was invalid.',
    super.statusCode = 422,
    this.fieldErrors = const {},
    super.details,
  });

  @override
  List<Object?> get props => [message, statusCode, fieldErrors, details];
}

/// Thrown when the remote server encounters an internal error (HTTP 500-599).
class ServerException extends AppException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.statusCode = 500,
    super.details,
  });
}

/// Catch-all for unclassified errors.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.statusCode,
    super.details,
  });
}
