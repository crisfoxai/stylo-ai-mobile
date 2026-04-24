import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/style_profile.dart';

class StyleProfileRemoteDataSource {
  final Dio _dio;

  StyleProfileRemoteDataSource(this._dio);

  Future<StyleProfile> getProfile() async {
    final response = await _dio.get(Endpoints.styleProfile);
    return StyleProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<StyleProfile> submitQuiz(Map<String, dynamic> answers) async {
    final response = await _dio.post(Endpoints.styleProfile, data: answers);
    return StyleProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
