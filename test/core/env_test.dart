import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/env.dart';

void main() {
  group('Env', () {
    test('isDev returns a boolean', () {
      expect(Env.isDev, isA<bool>());
    });

    test('isStaging returns a boolean', () {
      expect(Env.isStaging, isA<bool>());
    });

    test('isProd returns a boolean', () {
      expect(Env.isProd, isA<bool>());
    });

    test('exactly one environment flag is true', () {
      final activeFlags =
          [Env.isDev, Env.isStaging, Env.isProd].where((f) => f).length;
      expect(activeFlags, 1);
    });

    test('apiBaseUrl has a default value', () {
      expect(Env.apiBaseUrl, isNotEmpty);
    });
  });
}
