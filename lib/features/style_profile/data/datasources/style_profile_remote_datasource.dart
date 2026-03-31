import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../models/style_profile_model.dart';

class StyleProfileRemoteDataSource {
  final Dio _dio;

  StyleProfileRemoteDataSource(this._dio);

  Future<StyleProfileModel> getProfile() async {
    final response = await _dio.get(Endpoints.styleProfile);
    return StyleProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<StyleProfileModel> submitQuiz(Map<String, dynamic> answers) async {
    final response = await _dio.post(Endpoints.styleProfile, data: answers);
    return StyleProfileModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
