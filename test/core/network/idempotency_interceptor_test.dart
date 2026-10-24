import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/network/idempotency_interceptor.dart';

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late MockRequestInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/test'));
  });

  setUp(() {
    mockHandler = MockRequestInterceptorHandler();
  });

  group('IdempotencyInterceptor', () {
    test('injects Idempotency-Key on POST requests', () {
      final interceptor = IdempotencyInterceptor(
        customGenerator: () => 'fixed-uuid-v7-key',
      );
      final options = RequestOptions(method: 'POST', path: '/cases');

      interceptor.onRequest(options, mockHandler);

      expect(options.headers['Idempotency-Key'], equals('fixed-uuid-v7-key'));
      verify(() => mockHandler.next(options)).called(1);
    });

    test('injects Idempotency-Key on PUT, PATCH, and DELETE requests', () {
      final interceptor = IdempotencyInterceptor(
        customGenerator: () => 'mutating-key',
      );

      for (final method in ['PUT', 'PATCH', 'DELETE']) {
        final options = RequestOptions(method: method, path: '/resource');
        interceptor.onRequest(options, mockHandler);
        expect(options.headers['Idempotency-Key'], equals('mutating-key'));
      }
    });

    test('does NOT inject Idempotency-Key on GET or HEAD requests', () {
      final interceptor = IdempotencyInterceptor(
        customGenerator: () => 'should-not-be-injected',
      );

      for (final method in ['GET', 'HEAD', 'OPTIONS']) {
        final options = RequestOptions(method: method, path: '/patients');
        interceptor.onRequest(options, mockHandler);
        expect(options.headers.containsKey('Idempotency-Key'), isFalse);
      }
    });

    test('preserves existing Idempotency-Key without overwriting', () {
      final interceptor = IdempotencyInterceptor(
        customGenerator: () => 'new-key',
      );
      final options = RequestOptions(
        method: 'POST',
        path: '/cases',
        headers: {'Idempotency-Key': 'client-preset-idempotency-key'},
      );

      interceptor.onRequest(options, mockHandler);

      expect(options.headers['Idempotency-Key'], equals('client-preset-idempotency-key'));
    });
  });
}
