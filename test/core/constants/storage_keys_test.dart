import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/constants/storage_keys.dart';

void main() {
  group('StorageKeys', () {
    test('accessToken key', () {
      expect(StorageKeys.accessToken, 'access_token');
    });

    test('refreshToken key', () {
      expect(StorageKeys.refreshToken, 'refresh_token');
    });

    test('userId key', () {
      expect(StorageKeys.userId, 'user_id');
    });

    test('onboardingComplete key', () {
      expect(StorageKeys.onboardingComplete, 'onboarding_complete');
    });

    test('themeMode key', () {
      expect(StorageKeys.themeMode, 'theme_mode');
    });

    test('hasCompletedStyleQuiz key', () {
      expect(StorageKeys.hasCompletedStyleQuiz, 'has_completed_style_quiz');
    });

    test('fcmToken key', () {
      expect(StorageKeys.fcmToken, 'fcm_token');
    });
  });
}
