import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/core/config/app_env.dart';

void main() {
  group('AppEnv Configuration', () {
    test('provides sensible defaults for local development', () {
      expect(AppEnv.apiBaseUrl, isNotEmpty);
      expect(AppEnv.appEnv, equals('development'));
      expect(AppEnv.isDevelopment, isTrue);
      expect(AppEnv.isProduction, isFalse);
      expect(AppEnv.r2StorageEndpoint, isNotEmpty);
    });
  });
}
