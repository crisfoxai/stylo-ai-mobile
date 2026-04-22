import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';

class TryOnRemoteDataSource {
  final Dio _dio;

  TryOnRemoteDataSource(this._dio);

  Future<String> tryOn({
    required String outfitId,
    required File userPhoto,
  }) async {
    final formData = FormData.fromMap({
      'outfitId': outfitId,
      'photo': await MultipartFile.fromFile(
        userPhoto.path,
        filename: 'tryon.jpg',
      ),
    });

    final response = await _dio.post(
      Endpoints.tryOn,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data['data']['resultUrl'] as String;
  }
}
