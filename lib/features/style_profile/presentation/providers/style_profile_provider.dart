import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/style_profile_remote_datasource.dart';
import '../../data/repositories/style_profile_repository_impl.dart';
import '../../domain/entities/style_profile.dart';
import '../../domain/repositories/style_profile_repository.dart';

final styleProfileRepositoryProvider = Provider<StyleProfileRepository>((ref) {
  return StyleProfileRepositoryImpl(
    StyleProfileRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class StyleQuizState {
  final int currentQuestion;
  final Map<int, List<String>> answers;
  final bool isSubmitting;
  final bool isComplete;
  final StyleProfile? result;
  final String? error;

  const StyleQuizState({
    this.currentQuestion = 0,
    this.answers = const {},
    this.isSubmitting = false,
    this.isComplete = false,
    this.result,
    this.error,
  });

  StyleQuizState copyWith({
    int? currentQuestion,
    Map<int, List<String>>? answers,
    bool? isSubmitting,
    bool? isComplete,
    StyleProfile? result,
    String? error,
  }) => StyleQuizState(
    currentQuestion: currentQuestion ?? this.currentQuestion,
    answers: answers ?? this.answers,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isComplete: isComplete ?? this.isComplete,
    result: result ?? this.result,
    error: error,
  );
}

class StyleQuizNotifier extends StateNotifier<StyleQuizState> {
  final StyleProfileRepository _repository;

  StyleQuizNotifier(this._repository) : super(const StyleQuizState());

  static const int totalQuestions = 5;

  void selectAnswer(int questionIndex, String answer) {
    final current = Map<int, List<String>>.from(state.answers);
    final answers = List<String>.from(current[questionIndex] ?? []);
    if (answers.contains(answer)) {
      answers.remove(answer);
    } else {
      answers.add(answer);
    }
    current[questionIndex] = answers;
    state = state.copyWith(answers: current);
  }

  void nextQuestion() {
    if (state.currentQuestion < totalQuestions - 1) {
      state = state.copyWith(currentQuestion: state.currentQuestion + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestion > 0) {
      state = state.copyWith(currentQuestion: state.currentQuestion - 1);
    }
  }

  Future<void> submitQuiz() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final answers = state.answers;
      final quizData = {
        'aesthetics': answers[0] ?? [],
        'favoriteColors': answers[1] ?? [],
        'occasions': answers[2] ?? [],
        'adventureLevel': (answers[3] ?? ['moderate']).first,
        'priorities': answers[4] ?? [],
      };
      final profile = await _repository.submitQuiz(quizData);
      state = state.copyWith(isSubmitting: false, isComplete: true, result: profile);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final styleQuizNotifierProvider =
    StateNotifierProvider<StyleQuizNotifier, StyleQuizState>((ref) {
  return StyleQuizNotifier(ref.watch(styleProfileRepositoryProvider));
});

final styleProfileProvider = FutureProvider<StyleProfile?>((ref) async {
  try {
    return await ref.watch(styleProfileRepositoryProvider).getProfile();
  } catch (_) {
    return null;
  }
});
