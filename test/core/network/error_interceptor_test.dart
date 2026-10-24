import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/core/network/error_interceptor.dart';

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/test')),
    );
  });

  setUp(() {
    interceptor = ErrorInterceptor();
    mockHandler = MockErrorInterceptorHandler();
  });

  group('ErrorInterceptor & parseDioException', () {
    test('maps connectionError to NetworkException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
        message: 'Failed to connect to host',
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<NetworkException>());
    });

    test('maps connectionTimeout to NetworkException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<NetworkException>());
    });

    test('maps HTTP 401 to UnauthorizedException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/me'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/me'),
          statusCode: 401,
          data: {'message': 'Unauthenticated.'},
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<UnauthorizedException>());
      expect(domainEx.message, equals('Unauthenticated.'));
      expect(domainEx.statusCode, equals(401));
    });

    test('maps HTTP 403 to ForbiddenException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/cases'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/cases'),
          statusCode: 403,
          data: {'message': 'Tenant scope invalid for user.'},
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<ForbiddenException>());
      expect(domainEx.statusCode, equals(403));
    });

    test('maps HTTP 404 to NotFoundException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/patients/9999'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/patients/9999'),
          statusCode: 404,
          data: {'message': 'Patient not found.'},
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<NotFoundException>());
    });

    test('maps HTTP 409 to ConflictException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/cases'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/cases'),
          statusCode: 409,
          data: {'message': 'Idempotent request replay detected.'},
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<ConflictException>());
    });

    test('maps HTTP 422 to ValidationException with parsed field errors', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 422,
          data: {
            'message': 'The given data was invalid.',
            'errors': {
              'email': ['The email field is required.'],
              'password': ['The password must be at least 8 characters.'],
            },
          },
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<ValidationException>());
      final validationEx = domainEx as ValidationException;
      expect(validationEx.statusCode, equals(422));
      expect(validationEx.fieldErrors.containsKey('email'), isTrue);
      expect(validationEx.fieldErrors['email'], contains('The email field is required.'));
      expect(validationEx.fieldErrors['password'], contains('The password must be at least 8 characters.'));
    });

    test('maps HTTP 500 to ServerException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/api/v1/cases'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/cases'),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
      );

      final domainEx = ErrorInterceptor.parseDioException(dioErr);
      expect(domainEx, isA<ServerException>());
      expect(domainEx.statusCode, equals(500));
    });

    test('onError calls handler.next with transformed DioException wrapping domain AppException', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      interceptor.onError(dioErr, mockHandler);

      final captured = verify(() => mockHandler.next(captureAny())).captured;
      expect(captured.first, isA<DioException>());
      final capturedDioError = captured.first as DioException;
      expect(capturedDioError.error, isA<NetworkException>());
    });
  });
}
