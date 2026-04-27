import 'package:dio/dio.dart';
import '../../domain/entities/try_on_result.dart';

class TryOnRemoteDataSource {
  final Dio _dio;

  TryOnRemoteDataSource(this._dio);

  Future<TryOnResult> startTryOn({
    required String imagePath,
    required String garmentId,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      'garmentId': garmentId,
    });
    final response = await _dio.post('/tryon', data: formData);
    final data = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : response.data as Map<String, dynamic>;
    return TryOnResult.fromJson(data);
  }

  /// POST /tryon/outfit — sequential multi-garment tryon pipeline.
  /// Returns the final result image URL.
  Future<String> tryOnOutfit(List<Map<String, String>> garments) async {
    final response = await _dio.post('/tryon/outfit', data: {'garments': garments});
    final body = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : response.data as Map<String, dynamic>;
    return body['resultImageUrl'] as String;
  }
}
