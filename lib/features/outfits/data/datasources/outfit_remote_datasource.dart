import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/outfit.dart';

class OutfitRemoteDataSource {
  final Dio _dio;

  OutfitRemoteDataSource(this._dio);

  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
  }) async {
    final response = await _dio.post(Endpoints.generateOutfit, data: {
      'mood': mood,
      'event': event,
    });
    return Outfit.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfits,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Outfit> getOutfit(String id) async {
    final response = await _dio.get(Endpoints.outfit(id));
    return Outfit.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Outfit> toggleFavorite(String id) async {
    final response = await _dio.post(Endpoints.toggleFavorite(id));
    return Outfit.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Outfit> logWorn(String id) async {
    final response = await _dio.post(Endpoints.logWorn(id));
    return Outfit.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Outfit>> getFavorites() async {
    final response = await _dio.get(Endpoints.favorites);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfitHistory,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
