import 'package:dio/dio.dart';

/// Interceptor that automatically injects the `Accept-Language` HTTP header
/// based on the active application locale ('en' or 'ar').
class LocaleInterceptor extends Interceptor {
  static const String headerAcceptLanguage = 'Accept-Language';

  final String Function() _localeProvider;

  LocaleInterceptor({required String Function() localeProvider})
      : _localeProvider = localeProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey(headerAcceptLanguage)) {
      options.headers[headerAcceptLanguage] = _localeProvider();
    }
    handler.next(options);
  }
}
