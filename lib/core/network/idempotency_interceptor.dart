import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Interceptor that automatically injects an RFC 9562 UUID v7 `Idempotency-Key` header
/// into all state-modifying HTTP requests (POST, PUT, PATCH, DELETE).
///
/// Prevents accidental double-charging, duplicate clinical record creation,
/// and duplicate inventory decrements during mobile network reconnections.
class IdempotencyInterceptor extends Interceptor {
  static const String headerIdempotencyKey = 'Idempotency-Key';

  static const Set<String> _mutatingMethods = {
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
  };

  final Uuid _uuid;
  final String Function()? _customGenerator;

  IdempotencyInterceptor({
    Uuid? uuid,
    String Function()? customGenerator,
  })  : _uuid = uuid ?? const Uuid(),
        _customGenerator = customGenerator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();

    // Only inject idempotency keys on mutating HTTP verbs
    if (_mutatingMethods.contains(method)) {
      final existingKey = options.headers[headerIdempotencyKey];
      if (existingKey == null || existingKey.toString().trim().isEmpty) {
        final newKey = _customGenerator != null
            ? _customGenerator!()
            : _uuid.v7();
        options.headers[headerIdempotencyKey] = newKey;
      }
    }

    handler.next(options);
  }
}
