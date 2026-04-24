import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylo_ai/core/network/api_client.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('apiClientProvider', () {
    late ProviderContainer container;
    late _MockFirebaseAuth mockAuth;

    setUp(() async {
      mockAuth = _MockFirebaseAuth();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('creates a Dio instance', () {
      final dio = container.read(apiClientProvider);
      expect(dio, isA<Dio>());
    });

    test('has correct Content-Type header', () {
      final dio = container.read(apiClientProvider);
      expect(dio.options.headers['Content-Type'], 'application/json');
    });

    test('has correct Accept header', () {
      final dio = container.read(apiClientProvider);
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('has interceptors configured', () {
      final dio = container.read(apiClientProvider);
      expect(dio.interceptors.length, greaterThanOrEqualTo(2));
    });

    test('uses the API base URL from Env', () {
      final dio = container.read(apiClientProvider);
      expect(dio.options.baseUrl, isNotEmpty);
      expect(dio.options.baseUrl.startsWith('https://'), isTrue);
    });
  });
}
