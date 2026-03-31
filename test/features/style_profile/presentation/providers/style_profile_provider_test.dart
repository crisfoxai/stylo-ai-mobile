import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/style_profile/domain/entities/style_profile.dart';
import 'package:stylo_ai/features/style_profile/domain/repositories/style_profile_repository.dart';
import 'package:stylo_ai/features/style_profile/presentation/providers/style_profile_provider.dart';

class FakeStyleProfileRepository implements StyleProfileRepository {
  Exception? errorToThrow;
  Map<String, dynamic>? lastQuizData;

  StyleProfile _makeProfile() => StyleProfile(
        id: 'sp-1',
        aesthetics: const ['minimalist', 'classic'],
        favoriteColors: const ['black', 'white'],
        occasions: const ['work', 'casual'],
        adventureLevel: 'moderate',
        priorities: const ['comfort', 'style'],
        createdAt: DateTime(2024),
      );

  @override
  Future<StyleProfile> getProfile() async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return _makeProfile();
  }

  @override
  Future<StyleProfile> submitQuiz(Map<String, dynamic> answers) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    lastQuizData = answers;
    return _makeProfile();
  }
}

ProviderContainer makeContainer(FakeStyleProfileRepository repo) {
  return ProviderContainer(
    overrides: [styleProfileRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  late FakeStyleProfileRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeStyleProfileRepository();
    container = makeContainer(fakeRepo);
  });

  tearDown(() => container.dispose());

  group('StyleQuizState', () {
    test('default has sensible defaults', () {
      const state = StyleQuizState();
      expect(state.currentQuestion, 0);
      expect(state.answers, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.isComplete, isFalse);
      expect(state.result, isNull);
      expect(state.error, isNull);
    });

    test('copyWith overrides specified fields', () {
      const state = StyleQuizState();
      final updated = state.copyWith(currentQuestion: 2, isSubmitting: true);
      expect(updated.currentQuestion, 2);
      expect(updated.isSubmitting, isTrue);
    });
  });

  group('StyleQuizNotifier.selectAnswer', () {
    test('adds answer to question', () {
      container
          .read(styleQuizNotifierProvider.notifier)
          .selectAnswer(0, 'minimalist');
      final state = container.read(styleQuizNotifierProvider);
      expect(state.answers[0], contains('minimalist'));
    });

    test('removes answer when already selected', () {
      final notifier = container.read(styleQuizNotifierProvider.notifier);
      notifier.selectAnswer(0, 'minimalist');
      notifier.selectAnswer(0, 'minimalist');
      final state = container.read(styleQuizNotifierProvider);
      expect(state.answers[0], isEmpty);
    });

    test('allows multiple answers per question', () {
      final notifier = container.read(styleQuizNotifierProvider.notifier);
      notifier.selectAnswer(0, 'minimalist');
      notifier.selectAnswer(0, 'classic');
      final state = container.read(styleQuizNotifierProvider);
      expect(state.answers[0], ['minimalist', 'classic']);
    });
  });

  group('StyleQuizNotifier.nextQuestion', () {
    test('increments current question', () {
      container.read(styleQuizNotifierProvider.notifier).nextQuestion();
      expect(container.read(styleQuizNotifierProvider).currentQuestion, 1);
    });

    test('does not exceed total questions', () {
      final notifier = container.read(styleQuizNotifierProvider.notifier);
      for (var i = 0; i < 10; i++) {
        notifier.nextQuestion();
      }
      expect(container.read(styleQuizNotifierProvider).currentQuestion,
          StyleQuizNotifier.totalQuestions - 1);
    });
  });

  group('StyleQuizNotifier.previousQuestion', () {
    test('decrements current question', () {
      final notifier = container.read(styleQuizNotifierProvider.notifier);
      notifier.nextQuestion();
      notifier.nextQuestion();
      notifier.previousQuestion();
      expect(container.read(styleQuizNotifierProvider).currentQuestion, 1);
    });

    test('does not go below 0', () {
      container.read(styleQuizNotifierProvider.notifier).previousQuestion();
      expect(container.read(styleQuizNotifierProvider).currentQuestion, 0);
    });
  });

  group('StyleQuizNotifier.submitQuiz', () {
    test('submits answers and sets result on success', () async {
      final notifier = container.read(styleQuizNotifierProvider.notifier);
      notifier.selectAnswer(0, 'minimalist');
      notifier.selectAnswer(1, 'black');
      notifier.selectAnswer(2, 'work');
      notifier.selectAnswer(3, 'moderate');
      notifier.selectAnswer(4, 'comfort');

      await notifier.submitQuiz();

      final state = container.read(styleQuizNotifierProvider);
      expect(state.isComplete, isTrue);
      expect(state.isSubmitting, isFalse);
      expect(state.result, isNotNull);
      expect(state.result!.id, 'sp-1');
    });

    test('sets error on failure', () async {
      fakeRepo.errorToThrow = Exception('Server error');
      await container.read(styleQuizNotifierProvider.notifier).submitQuiz();

      final state = container.read(styleQuizNotifierProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.error, contains('Server error'));
      expect(state.isComplete, isFalse);
    });
  });
}
