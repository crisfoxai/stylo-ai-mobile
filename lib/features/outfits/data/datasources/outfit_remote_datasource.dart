import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../models/outfit_model.dart';

class OutfitRemoteDataSource {
  final Dio _dio;

  OutfitRemoteDataSource(this._dio);

  Future<OutfitModel> generateOutfit({
    required String mood,
    required String event,
  }) async {
    final response = await _dio.post(Endpoints.generateOutfit, data: {
      'mood': mood,
      'event': event,
    });
    return OutfitModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OutfitModel>> getOutfits({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfits,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => OutfitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OutfitModel> getOutfit(String id) async {
    final response = await _dio.get(Endpoints.outfit(id));
    return OutfitModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<OutfitModel> toggleFavorite(String id) async {
    final response = await _dio.post(Endpoints.toggleFavorite(id));
    return OutfitModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<OutfitModel> logWorn(String id) async {
    final response = await _dio.post(Endpoints.logWorn(id));
    return OutfitModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OutfitModel>> getFavorites() async {
    final response = await _dio.get(Endpoints.favorites);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => OutfitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OutfitModel>> getHistory({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfitHistory,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => OutfitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
