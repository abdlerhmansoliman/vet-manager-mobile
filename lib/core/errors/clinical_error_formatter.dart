import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'app_exceptions.dart';

/// Centralized utility for formatting exceptions and system errors into
/// human-friendly, clinical, and reassuring user-facing messages.
///
/// Guaranteed to never expose raw stack traces, database column names,
/// SQL queries, or internal exceptions to the end user.
class ClinicalErrorFormatter {
  ClinicalErrorFormatter._();

  /// Translates any error or exception into a polished, user-friendly message.
  /// Also logs the technical error to [debugPrint] for diagnosis.
  static String format(Object? error, {String? fallbackMessage}) {
    if (error == null) {
      return fallbackMessage ?? 'An unexpected error occurred. Please try again.';
    }

    // Log the raw technical error in debug mode for developer diagnostics
    debugPrint('[ClinicalErrorFormatter] Intercepted error: $error');

    // 1. Domain AppException
    if (error is AppException) {
      return _formatAppException(error, fallbackMessage: fallbackMessage);
    }

    // 2. Dio Network Exception
    if (error is DioException) {
      return _formatDioException(error, fallbackMessage: fallbackMessage);
    }

    // 3. Drift InvalidDataException (Form & Schema constraints)
    if (error is InvalidDataException) {
      return _formatInvalidDataException(error);
    }

    // 4. Socket & Connection exceptions (offline mode)
    if (error is SocketException || error is TimeoutException) {
      return 'Network connection is unavailable. Changes are saved locally.';
    }

    // 5. FormatException (e.g. invalid number input)
    if (error is FormatException) {
      return 'Please ensure numbers and formatted fields are entered correctly.';
    }

    // 6. Inspect error string patterns for common SQLite / Drift / OS issues
    final errStr = error.toString();

    // Check for Drift InvalidDataException if wrapped in another exception
    if (errStr.contains('InvalidDataException')) {
      return _parseInvalidDataString(errStr);
    }

    // SQLite Unique Constraint
    if (errStr.contains('UNIQUE constraint failed') ||
        errStr.contains('SqliteException(1555)') ||
        errStr.contains('SqliteException(2067)')) {
      return 'A record with this identifier already exists in the system.';
    }

    // SQLite Foreign Key
    if (errStr.contains('FOREIGN KEY constraint failed') ||
        errStr.contains('SqliteException(787)')) {
      return 'Unable to save record due to a missing associated record. Please refresh and try again.';
    }

    // Connection refused / Network
    if (errStr.contains('Connection refused') ||
        errStr.contains('Network is unreachable') ||
        errStr.contains('Failed host lookup')) {
      return 'Unable to connect to the clinic server. Changes are saved locally.';
    }

    // Return the custom fallback or a clean clinical default
    return fallbackMessage ?? 'Unable to complete the operation. Please try again.';
  }

  static String _formatAppException(AppException e, {String? fallbackMessage}) {
    if (e is ValidationException) {
      if (e.fieldErrors.isNotEmpty) {
        // Return first validation error message cleanly
        final firstField = e.fieldErrors.entries.first;
        final firstErr = firstField.value.isNotEmpty ? firstField.value.first : null;
        if (firstErr != null && firstErr.isNotEmpty) {
          return firstErr;
        }
      }
      return 'Please check the entered information and correct any highlighted errors.';
    }

    if (e is NetworkException) {
      return 'You are currently working offline. Data will sync automatically when connected.';
    }

    if (e is UnauthorizedException) {
      return 'Your session has expired. Please log in again to continue.';
    }

    if (e is ForbiddenException) {
      return 'You do not have permission to perform this clinical action.';
    }

    if (e is NotFoundException) {
      return 'The requested record could not be found or has been removed.';
    }

    if (e is ConflictException) {
      return 'This record was recently updated on another device. Please refresh to see the latest version.';
    }

    if (e is ServerException) {
      return 'The clinic server is temporarily unavailable. Your changes are safely stored offline.';
    }

    // If message is human readable and doesn't contain raw code artifacts
    if (e.message.isNotEmpty && !_isRawTechnicalString(e.message)) {
      return e.message;
    }

    return fallbackMessage ?? 'An unexpected error occurred. Please try again.';
  }

  static String _formatDioException(DioException e, {String? fallbackMessage}) {
    if (e.error is AppException) {
      return _formatAppException(e.error as AppException, fallbackMessage: fallbackMessage);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server connection timed out. Changes are stored locally and will sync later.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to clinic server. Working in offline-first mode.';
      case DioExceptionType.badCertificate:
        return 'Secure connection could not be established with the server.';
      case DioExceptionType.cancel:
        return 'The operation was cancelled.';
      default:
        return fallbackMessage ?? 'A network communication error occurred. Changes are saved locally.';
    }
  }

  static String _formatInvalidDataException(InvalidDataException e) {
    return _parseInvalidDataString(e.toString());
  }

  static String _parseInvalidDataString(String errStr) {
    if (errStr.contains('phonePrimary') || errStr.contains('phone')) {
      return 'Primary phone number must be at least 3 digits.';
    }
    if (errStr.contains('nameOrTag') || errStr.contains('name')) {
      return 'Please enter a valid name or tag.';
    }
    if (errStr.contains('microchip')) {
      return 'Microchip identifier cannot exceed 32 characters.';
    }
    if (errStr.contains('earTag')) {
      return 'Ear tag number cannot exceed 64 characters.';
    }
    if (errStr.contains('breed')) {
      return 'Breed text is too long.';
    }
    if (errStr.contains('currentWeightKg') || errStr.contains('weight')) {
      return 'Please enter a valid weight in kilograms.';
    }
    return 'Please check the entered information. Some fields have invalid or incomplete data.';
  }

  static bool _isRawTechnicalString(String str) {
    final lower = str.toLowerCase();
    return lower.contains('exception') ||
        lower.contains('sqlite') ||
        lower.contains('syntaxerror') ||
        lower.contains('nullcheckoperator') ||
        lower.contains('nosuchmethoderror') ||
        lower.contains('dioerror') ||
        lower.contains('table') ||
        lower.contains('column') ||
        lower.contains('failed host lookup');
  }
}

/// Backward compatibility alias
typedef ErrorFormatter = ClinicalErrorFormatter;
