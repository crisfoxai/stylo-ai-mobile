import 'package:dio/dio.dart';
import '../../../../core/network/backend_compat.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../domain/entities/garment.dart';

class WardrobeRemoteDataSource {
  final Dio _dio;

  WardrobeRemoteDataSource(this._dio);

  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (filters != null) ...filters,
    };

    final response = await _fetchGarments(queryParams);
    final raw = response.data;

    final items = BackendCompat.extractList(raw)
        .cast<Map<String, dynamic>>()
        .map(BackendCompat.normalizeMongoId)
        .map(Garment.fromJson)
        .toList();

    final total = BackendCompat.extractTotal(raw, items.length);
    final hasMore = items.length == limit;

    return PaginatedGarments(
      items: items,
      total: total,
      page: page,
      limit: limit,
      hasMore: hasMore,
    );
  }

  Future<Response> _fetchGarments(Map<String, dynamic> queryParams) async {
    try {
      return await _dio.get(Endpoints.garments, queryParameters: queryParams);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return await _dio.get(Endpoints.wardrobeGarments, queryParameters: queryParams);
      }
      rethrow;
    }
  }

  Future<Garment> getGarment(String id) async {
    late Response response;
    try {
      response = await _dio.get(Endpoints.garment(id));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get(Endpoints.wardrobeGarment(id));
      } else {
        rethrow;
      }
    }
    return Garment.fromJson(BackendCompat.normalizeMongoId(BackendCompat.extractMap(response.data)));
  }

  Future<ScanJobResult> scanGarment(String imagePath) async {
    final fileName = imagePath.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });

    late Response response;
    try {
      response = await _dio.post(
        Endpoints.scanUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.post(
          Endpoints.wardrobeScanUpload,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        rethrow;
      }
    }

    final data = BackendCompat.extractMap(response.data);
    return ScanJobResult(
      jobId: data['jobId'] as String? ?? '',
      status: data['status'] as String? ?? 'processing',
    );
  }

  Future<ScanJobStatus> checkScanJob(String jobId) async {
    late Response response;
    try {
      response = await _dio.get(Endpoints.garmentJob(jobId));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.get(Endpoints.wardrobeGarmentJob(jobId));
      } else {
        rethrow;
      }
    }
    final data = BackendCompat.extractMap(response.data);

    Garment? garment;
    if (data['garment'] != null) {
      garment = Garment.fromJson(BackendCompat.normalizeMongoId(data['garment'] as Map<String, dynamic>));
    } else if (data['garmentId'] != null) {
      final garmentId = data['garmentId'] as String;
      garment = await getGarment(garmentId);
    }

    return ScanJobStatus(
      jobId: jobId,
      status: data['status'] as String? ?? 'processing',
      garment: garment,
      errorMessage: data['error'] as String?,
    );
  }

  Future<Garment> updateGarment(String id, Map<String, dynamic> data) async {
    late Response response;
    try {
      response = await _dio.patch(Endpoints.garment(id), data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        response = await _dio.patch(Endpoints.wardrobeGarment(id), data: data);
      } else {
        rethrow;
      }
    }
    return Garment.fromJson(BackendCompat.normalizeMongoId(BackendCompat.extractMap(response.data)));
  }

  Future<void> deleteGarment(String id) async {
    try {
      await _dio.delete(Endpoints.garment(id));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.delete(Endpoints.wardrobeGarment(id));
      } else {
        rethrow;
      }
    }
  }

  Future<List<Garment>> searchGarments(String query) async {
    final response = await _fetchGarments({'search': query, 'limit': 50});
    return BackendCompat.extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(BackendCompat.normalizeMongoId)
        .map(Garment.fromJson)
        .toList();
  }
}
