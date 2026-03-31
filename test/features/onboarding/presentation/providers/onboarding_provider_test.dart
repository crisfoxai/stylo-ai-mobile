import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylo_ai/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:stylo_ai/features/onboarding/presentation/providers/onboarding_provider.dart';

// ── Fake data source ──────────────────────────────────────────────────────────

class FakeOnboardingDataSource implements OnboardingLocalDataSource {
  bool _onboardingComplete;
  bool _styleQuizComplete;

  FakeOnboardingDataSource({
    bool onboardingComplete = false,
    bool styleQuizComplete = false,
  })  : _onboardingComplete = onboardingComplete,
        _styleQuizComplete = styleQuizComplete;

  @override
  bool get isOnboardingComplete => _onboardingComplete;

  @override
  Future<void> setOnboardingComplete() async {
    _onboardingComplete = true;
  }

  @override
  bool get hasCompletedStyleQuiz => _styleQuizComplete;

  @override
  Future<void> setStyleQuizComplete() async {
    _styleQuizComplete = true;
  }
}

ProviderContainer makeContainer({
  bool onboardingComplete = false,
  bool styleQuizComplete = false,
}) {
  final fakeDs = FakeOnboardingDataSource(
    onboardingComplete: onboardingComplete,
    styleQuizComplete: styleQuizComplete,
  );
  return ProviderContainer(
    overrides: [
      onboardingDataSourceProvider.overrideWithValue(fakeDs),
    ],
  );
}

void main() {
  group('onboardingCompleteProvider', () {
    test('returns false when style quiz has not been completed', () {
      final container = makeContainer(styleQuizComplete: false);
      addTearDown(container.dispose);
      expect(container.read(onboardingCompleteProvider), isFalse);
    });

    test('returns true when style quiz has been completed', () {
      final container = makeContainer(styleQuizComplete: true);
      addTearDown(container.dispose);
      expect(container.read(onboardingCompleteProvider), isTrue);
    });
  });

  group('onboardingPageProvider', () {
    test('initial page is 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(onboardingPageProvider), 0);
    });

    test('can be updated to page 1', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(onboardingPageProvider.notifier).state = 1;
      expect(container.read(onboardingPageProvider), 1);
    });

    test('can be updated to last page (2)', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(onboardingPageProvider.notifier).state = 2;
      expect(container.read(onboardingPageProvider), 2);
    });
  });

  group('OnboardingLocalDataSource', () {
    test('isOnboardingComplete initially false with empty SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = OnboardingLocalDataSource(prefs);
      expect(ds.isOnboardingComplete, isFalse);
    });

    test('isOnboardingComplete true after setOnboardingComplete', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = OnboardingLocalDataSource(prefs);
      await ds.setOnboardingComplete();
      expect(ds.isOnboardingComplete, isTrue);
    });

    test('hasCompletedStyleQuiz initially false with empty SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = OnboardingLocalDataSource(prefs);
      expect(ds.hasCompletedStyleQuiz, isFalse);
    });

    test('hasCompletedStyleQuiz true after setStyleQuizComplete', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ds = OnboardingLocalDataSource(prefs);
      await ds.setStyleQuizComplete();
      expect(ds.hasCompletedStyleQuiz, isTrue);
    });

    test('reads pre-existing values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'has_completed_style_quiz': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final ds = OnboardingLocalDataSource(prefs);
      expect(ds.isOnboardingComplete, isTrue);
      expect(ds.hasCompletedStyleQuiz, isTrue);
    });
  });
}
