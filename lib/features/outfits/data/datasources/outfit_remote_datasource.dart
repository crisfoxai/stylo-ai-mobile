import 'package:dio/dio.dart';
import '../../../../core/network/backend_compat.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/outfit.dart';

class OutfitRemoteDataSource {
  final Dio _dio;

  OutfitRemoteDataSource(this._dio);

  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) async {
    final response = await _dio.post(Endpoints.generateOutfit, data: {
      'occasion': event,
      'mood': mood,
      if (excludeIds != null && excludeIds.isNotEmpty) 'excludeIds': excludeIds,
    });
    final data = BackendCompat.extractMap(response.data);
    return _normalizeOutfit(data);
  }

  Outfit _normalizeOutfit(Map<String, dynamic> data) {
    final rawId = (data['_id'] ?? data['id'] ?? '').toString();
    if (rawId.isNotEmpty) {
      return Outfit.fromJson({
        ...data,
        'id': rawId,
        'name': data['name'] ?? 'Outfit generado',
        'createdAt': data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      });
    }
    // Recommendation without a persisted id (some backend versions)
    return Outfit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Outfit ${data['mood'] ?? ''}',
      mood: data['mood'] as String?,
      occasion: (data['occasion'] ?? data['event']) as String?,
      garments: _parseGarments(data['garments']),
      createdAt: DateTime.now(),
    );
  }

  List<OutfitGarment> _parseGarments(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((g) {
          try {
            return OutfitGarment.fromJson(g);
          } catch (_) {
            return null;
          }
        })
        .whereType<OutfitGarment>()
        .toList();
  }

  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfits,
      queryParameters: {'page': page, 'limit': limit},
    );
    return BackendCompat.extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(Outfit.fromJson)
        .toList();
  }

  Future<Outfit> getOutfit(String id) async {
    final response = await _dio.get(Endpoints.outfit(id));
    return _normalizeOutfit(BackendCompat.extractMap(response.data));
  }

  Future<void> toggleFavorite(String id) async {
    // POST /outfits/:id/favorite returns 204 no body — ignore response
    await _dio.post(Endpoints.toggleFavorite(id));
  }

  Future<void> logWorn(String id) async {
    // POST /outfits/:id/worn returns WornEntry, not Outfit — ignore body
    await _dio.post(Endpoints.logWorn(id));
  }

  Future<List<Outfit>> getFavorites() async {
    final response = await _dio.get(Endpoints.favorites);
    return BackendCompat.extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(Outfit.fromJson)
        .toList();
  }

  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfitHistory,
      queryParameters: {'page': page, 'limit': limit},
    );
    return BackendCompat.extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(Outfit.fromJson)
        .toList();
  }
}
