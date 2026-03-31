import '../entities/style_profile.dart';

abstract class StyleProfileRepository {
  Future<StyleProfile> getProfile();
  Future<StyleProfile> submitQuiz(Map<String, dynamic> answers);
}
