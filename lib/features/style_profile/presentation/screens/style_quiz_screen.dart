import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../../../shared/widgets/stylo_chip.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/style_profile_provider.dart';

class StyleQuizScreen extends ConsumerWidget {
  const StyleQuizScreen({super.key});

  static const _questions = [
    _QuizQuestion(
      question: '¿Cómo describirías tu estilo?',
      options: ['Casual', 'Clásico', 'Streetwear', 'Minimalista', 'Boho', 'Elegante', 'Deportivo', 'Creativo'],
    ),
    _QuizQuestion(
      question: '¿Qué colores dominan tu guardarropa?',
      options: ['Negro', 'Blanco', 'Azul', 'Gris', 'Beige', 'Verde', 'Bordeaux', 'Pastel'],
    ),
    _QuizQuestion(
      question: '¿Para qué ocasiones te vestís más seguido?',
      options: ['Trabajo/oficina', 'Casual diario', 'Salidas nocturnas', 'Deporte/gym', 'Eventos formales', 'Home office'],
    ),
    _QuizQuestion(
      question: '¿Qué tan aventurero/a sos con la moda?',
      options: ['Me quedo con lo seguro', 'Pruebo cosas nuevas a veces', 'Me encanta experimentar', 'Soy trendsetter'],
    ),
    _QuizQuestion(
      question: '¿Cuál es tu prioridad al vestirte?',
      options: ['Comodidad', 'Estilo', 'Practicidad', 'Que combine bien', 'Expresar mi personalidad'],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(styleQuizNotifierProvider);
    final notifier = ref.read(styleQuizNotifierProvider.notifier);
    final currentQ = _questions[state.currentQuestion];

    ref.listen<StyleQuizState>(styleQuizNotifierProvider, (_, state) {
      if (state.isComplete) {
        ref.read(onboardingDataSourceProvider).setStyleQuizComplete();
        context.go('/style-quiz/result');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: state.currentQuestion > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: notifier.previousQuestion,
              )
            : null,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(onboardingDataSourceProvider).setStyleQuizComplete();
              context.go('/home');
            },
            child: const Text('Saltar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (state.currentQuestion + 1) / StyleQuizNotifier.totalQuestions,
                backgroundColor: AppColors.border,
                color: AppColors.accent,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Paso ${state.currentQuestion + 1} de ${StyleQuizNotifier.totalQuestions}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Question
              Text(
                currentQ.question,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Options
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: currentQ.options.map((option) {
                    final isSelected = (state.answers[state.currentQuestion] ?? []).contains(option);
                    return StyloChip(
                      label: option,
                      isSelected: isSelected,
                      onTap: () => notifier.selectAnswer(state.currentQuestion, option),
                    );
                  }).toList(),
                ),
              ),

              // Next button
              StyloButton(
                label: state.currentQuestion == StyleQuizNotifier.totalQuestions - 1
                    ? 'Descubrir mi estilo'
                    : 'Siguiente',
                onPressed: () {
                  if (state.currentQuestion == StyleQuizNotifier.totalQuestions - 1) {
                    notifier.submitQuiz();
                  } else {
                    notifier.nextQuestion();
                  }
                },
                isLoading: state.isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String question;
  final List<String> options;
  const _QuizQuestion({required this.question, required this.options});
}
