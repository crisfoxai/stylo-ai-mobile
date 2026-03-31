import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../models/garment_model.dart';

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

    final response = await _dio.get(
      Endpoints.garments,
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final meta = response.data['meta'] as Map<String, dynamic>?;
    final itemsList = data['items'] as List? ?? data['garments'] as List? ?? [];

    final items = itemsList
        .cast<Map<String, dynamic>>()
        .map(GarmentModel.fromJson)
        .toList();

    final total = meta?['total'] as int? ?? items.length;
    final hasMore = meta?['hasMore'] as bool? ?? (items.length == limit);

    return PaginatedGarments(
      items: items,
      total: total,
      page: page,
      limit: limit,
      hasMore: hasMore,
    );
  }

  Future<GarmentModel> getGarment(String id) async {
    final response = await _dio.get(Endpoints.garment(id));
    return GarmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<ScanJobResult> scanGarment(String imagePath) async {
    final fileName = imagePath.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });

    final response = await _dio.post(
      Endpoints.scanUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return ScanJobResult(
      jobId: data['jobId'] as String,
      status: data['status'] as String? ?? 'processing',
    );
  }

  Future<ScanJobStatus> checkScanJob(String jobId) async {
    final response = await _dio.get(Endpoints.garmentJob(jobId));
    final data = response.data['data'] as Map<String, dynamic>;

    GarmentModel? garment;
    if (data['garment'] != null) {
      garment = GarmentModel.fromJson(data['garment'] as Map<String, dynamic>);
    }

    return ScanJobStatus(
      jobId: jobId,
      status: data['status'] as String? ?? 'processing',
      garment: garment,
      errorMessage: data['error'] as String?,
    );
  }

  Future<GarmentModel> updateGarment(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(Endpoints.garment(id), data: data);
    return GarmentModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteGarment(String id) async {
    await _dio.delete(Endpoints.garment(id));
  }

  Future<List<GarmentModel>> searchGarments(String query) async {
    final response = await _dio.get(
      Endpoints.garments,
      queryParameters: {'search': query, 'limit': 50},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final itemsList = data['items'] as List? ?? data['garments'] as List? ?? [];

    return itemsList
        .cast<Map<String, dynamic>>()
        .map(GarmentModel.fromJson)
        .toList();
  }
}
