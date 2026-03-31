import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';

class OnboardingLocalDataSource {
  final SharedPreferences _prefs;

  OnboardingLocalDataSource(this._prefs);

  bool get isOnboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(StorageKeys.onboardingComplete, true);
  }

  bool get hasCompletedStyleQuiz =>
      _prefs.getBool(StorageKeys.hasCompletedStyleQuiz) ?? false;

  Future<void> setStyleQuizComplete() async {
    await _prefs.setBool(StorageKeys.hasCompletedStyleQuiz, true);
  }
}
