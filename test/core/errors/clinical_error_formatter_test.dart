import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/core/errors/clinical_error_formatter.dart';

void main() {
  group('ClinicalErrorFormatter', () {
    test('returns fallback for null error', () {
      expect(
        ClinicalErrorFormatter.format(null),
        'An unexpected error occurred. Please try again.',
      );
      expect(
        ClinicalErrorFormatter.format(null, fallbackMessage: 'Custom fallback'),
        'Custom fallback',
      );
    });

    test('formats ValidationException with fieldErrors', () {
      const ex = ValidationException(
        fieldErrors: {
          'phone': ['Phone is required', 'Must be valid'],
        },
      );
      expect(ClinicalErrorFormatter.format(ex), 'Phone is required');
    });

    test('formats empty ValidationException with reassuring instruction', () {
      const ex = ValidationException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'Please check the entered information and correct any highlighted errors.',
      );
    });

    test('formats NetworkException into offline message', () {
      const ex = NetworkException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'You are currently working offline. Data will sync automatically when connected.',
      );
    });

    test('formats UnauthorizedException into clean session message', () {
      const ex = UnauthorizedException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'Your session has expired. Please log in again to continue.',
      );
    });

    test('formats ForbiddenException into permission message', () {
      const ex = ForbiddenException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'You do not have permission to perform this clinical action.',
      );
    });

    test('formats NotFoundException into record not found message', () {
      const ex = NotFoundException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'The requested record could not be found or has been removed.',
      );
    });

    test('formats ConflictException into sync conflict message', () {
      const ex = ConflictException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'This record was recently updated on another device. Please refresh to see the latest version.',
      );
    });

    test('formats ServerException into offline storage notice', () {
      const ex = ServerException();
      expect(
        ClinicalErrorFormatter.format(ex),
        'The clinic server is temporarily unavailable. Your changes are safely stored offline.',
      );
    });

    test('formats Drift InvalidDataException on phonePrimary', () {
      final ex = InvalidDataException(
        'phonePrimary: Must at least be 3 characters long',
      );
      expect(
        ClinicalErrorFormatter.format(ex),
        'Primary phone number must be at least 3 digits.',
      );
    });

    test('formats Drift InvalidDataException on nameOrTag', () {
      final ex = InvalidDataException(
        'nameOrTag: Length cannot exceed 100 characters',
      );
      expect(
        ClinicalErrorFormatter.format(ex),
        'Please enter a valid name or tag.',
      );
    });

    test('formats Drift InvalidDataException on microchip', () {
      final ex = InvalidDataException(
        'microchipNumber: Length cannot exceed 32 characters',
      );
      expect(
        ClinicalErrorFormatter.format(ex),
        'Microchip identifier cannot exceed 32 characters.',
      );
    });

    test('formats generic InvalidDataException cleanly without companion dump', () {
      final ex = InvalidDataException(
        'Some internal Drift constraint failed on column xyz',
      );
      expect(
        ClinicalErrorFormatter.format(ex),
        'Please check the entered information. Some fields have invalid or incomplete data.',
      );
    });

    test('formats SocketException and TimeoutException into offline message', () {
      const socket = SocketException('Failed host lookup');
      final timeout = TimeoutException('Timeout occurred');

      expect(
        ClinicalErrorFormatter.format(socket),
        'Network connection is unavailable. Changes are saved locally.',
      );
      expect(
        ClinicalErrorFormatter.format(timeout),
        'Network connection is unavailable. Changes are saved locally.',
      );
    });

    test('formats SQLite UNIQUE constraint into friendly duplicate message', () {
      final ex = Exception('SqliteException(1555): UNIQUE constraint failed: clients.phone_primary');
      expect(
        ClinicalErrorFormatter.format(ex),
        'A record with this identifier already exists in the system.',
      );
    });

    test('formats SQLite FOREIGN KEY constraint cleanly', () {
      final ex = Exception('SqliteException(787): FOREIGN KEY constraint failed');
      expect(
        ClinicalErrorFormatter.format(ex),
        'Unable to save record due to a missing associated record. Please refresh and try again.',
      );
    });

    test('formats DioException connection timeout', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/sync'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        ClinicalErrorFormatter.format(dioErr),
        'Server connection timed out. Changes are stored locally and will sync later.',
      );
    });

    test('formats DioException wrapping domain AppException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/sync'),
        error: const NetworkException(),
      );
      expect(
        ClinicalErrorFormatter.format(dioErr),
        'You are currently working offline. Data will sync automatically when connected.',
      );
    });

    test('falls back gracefully on unknown exception without dumping technical text', () {
      final ex = Exception('Some internal framework crash at Line 42 NullPointerException');
      expect(
        ClinicalErrorFormatter.format(ex, fallbackMessage: 'Failed to complete update'),
        'Failed to complete update',
      );
    });
  });
}
