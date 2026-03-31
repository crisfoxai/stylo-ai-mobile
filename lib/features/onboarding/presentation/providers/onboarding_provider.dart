import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final onboardingDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingLocalDataSource(prefs);
});

final onboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(onboardingDataSourceProvider).hasCompletedStyleQuiz;
});

final onboardingPageProvider = StateProvider<int>((ref) => 0);
