import '../../domain/entities/style_profile.dart';
import '../../domain/repositories/style_profile_repository.dart';
import '../datasources/style_profile_remote_datasource.dart';

class StyleProfileRepositoryImpl implements StyleProfileRepository {
  final StyleProfileRemoteDataSource _remoteDataSource;

  StyleProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<StyleProfile> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<StyleProfile> submitQuiz(Map<String, dynamic> answers) =>
      _remoteDataSource.submitQuiz(answers);
}
