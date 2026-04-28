import 'dart:convert';
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

  /// POST /tryon/outfit — sequential multi-garment tryon pipeline (multipart).
  /// Sends userPhoto as file, garments as JSON string.
  /// Uses 180s timeout since N garments are processed sequentially (~30s each).
  Future<String> tryOnOutfit({
    required String imagePath,
    required List<Map<String, String>> garments,
    String? outfitId,
  }) async {
    final formData = FormData.fromMap({
      'userPhoto': await MultipartFile.fromFile(imagePath, filename: 'photo.jpg'),
      'garments': jsonEncode(garments),
      if (outfitId != null) 'outfitId': outfitId,
    });
    final response = await _dio.post(
      '/tryon/outfit',
      data: formData,
      options: Options(receiveTimeout: const Duration(seconds: 180)),
    );
    final body = response.data is Map<String, dynamic>
        ? (response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>)
        : response.data as Map<String, dynamic>;
    return body['resultImageUrl'] as String;
  }
}
