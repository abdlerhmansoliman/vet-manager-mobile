import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/core/network/locale_interceptor.dart';

void main() {
  group('LocaleInterceptor', () {
    test('injects Accept-Language header from locale provider', () {
      String currentLocale = 'en';
      final interceptor = LocaleInterceptor(localeProvider: () => currentLocale);

      final options = RequestOptions(path: '/api/v1/cases');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers[LocaleInterceptor.headerAcceptLanguage], equals('en'));

      currentLocale = 'ar';
      final arOptions = RequestOptions(path: '/api/v1/visits');
      final arHandler = RequestInterceptorHandler();
      interceptor.onRequest(arOptions, arHandler);

      expect(arOptions.headers[LocaleInterceptor.headerAcceptLanguage], equals('ar'));
    });

    test('preserves existing Accept-Language header if explicitly provided', () {
      final interceptor = LocaleInterceptor(localeProvider: () => 'ar');

      final options = RequestOptions(
        path: '/api/v1/patients',
        headers: {'Accept-Language': 'en-US'},
      );
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      expect(options.headers['Accept-Language'], equals('en-US'));
    });
  });
}
