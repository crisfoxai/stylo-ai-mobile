import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/backend_compat.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/services/calendar_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/share_card_result.dart';
import '../../presentation/providers/outfits_list_provider.dart';

class OutfitRemoteDataSource {
  final Dio _dio;

  OutfitRemoteDataSource(this._dio);

  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
    WeatherContext? weatherContext,
    List<CalendarEventContext>? calendarEvents,
  }) async {
    final response = await _dio.post(Endpoints.generateOutfit, data: {
      'occasion': event,
      'mood': mood,
      if (excludeIds != null && excludeIds.isNotEmpty) 'excludeIds': excludeIds,
      if (weatherContext != null) 'weatherContext': weatherContext.toJson(),
      if (calendarEvents != null && calendarEvents.isNotEmpty)
        'calendarEvents': calendarEvents.map((e) => e.toJson()).toList(),
    });
    final data = BackendCompat.extractMap(response.data);
    return _normalizeOutfit(data);
  }

  Outfit _normalizeOutfit(Map<String, dynamic> data) {
    final rawId = (data['_id'] ?? data['id'] ?? '').toString();
    final contextFactors = (data['contextFactors'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (rawId.isNotEmpty) {
      return Outfit.fromJson({
        ...data,
        'id': rawId,
        'name': data['name'] ?? 'Outfit generado',
        'createdAt': data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        'contextFactors': contextFactors,
      });
    }
    return Outfit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Outfit ${data['mood'] ?? ''}',
      mood: data['mood'] as String?,
      occasion: (data['occasion'] ?? data['event']) as String?,
      justification: data['justification'] as String?,
      contextFactors: contextFactors,
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
        .map(_normalizeOutfit)
        .toList();
  }

  Future<OutfitsPage> getAllPaged(OutfitsListFilter filter) async {
    final response = await _dio.get(Endpoints.outfits, queryParameters: {
      'page': filter.page,
      'limit': 20,
      'sort': filter.sort,
      if (filter.occasion != null) 'occasion': filter.occasion,
      if (filter.onlyFavorites) 'favorites': true,
      if (filter.onlyWithLookPhoto) 'hasLookPhoto': true,
    });
    final raw = response.data;
    // Backend may return { data: [...], total, page, totalPages } or plain list
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      final items = (raw['data'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(_normalizeOutfit)
          .toList();
      return OutfitsPage(
        data: items,
        total: (raw['total'] as num?)?.toInt() ?? items.length,
        page: (raw['page'] as num?)?.toInt() ?? filter.page,
        totalPages: (raw['totalPages'] as num?)?.toInt() ?? 1,
      );
    }
    // Fallback: plain list
    final items = BackendCompat.extractList(raw)
        .cast<Map<String, dynamic>>()
        .map(_normalizeOutfit)
        .toList();
    return OutfitsPage(data: items, total: items.length, page: 1, totalPages: 1);
  }

  Future<Map<String, dynamic>> uploadLookPhoto(
      String outfitId, String filePath) async {
    final file = File(filePath);
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    final response =
        await _dio.post(Endpoints.outfitLookPhoto(outfitId), data: formData);
    return BackendCompat.extractMap(response.data);
  }

  Future<void> deleteLookPhoto(String outfitId) async {
    await _dio.delete(Endpoints.outfitLookPhoto(outfitId));
  }

  Future<Outfit> getOutfit(String id) async {
    final response = await _dio.get(Endpoints.outfit(id));
    return _normalizeOutfit(BackendCompat.extractMap(response.data));
  }

  Future<void> toggleFavorite(String id, {bool wasFavorite = false}) async {
    if (wasFavorite) {
      await _dio.delete(Endpoints.toggleFavorite(id));
    } else {
      await _dio.post(Endpoints.toggleFavorite(id));
    }
  }

  Future<void> logWorn(String id) async {
    // POST /outfits/:id/worn returns WornEntry, not Outfit — ignore body
    await _dio.post(Endpoints.logWorn(id));
  }

  Future<List<Outfit>> getFavorites() async {
    final response = await _dio.get(Endpoints.favorites);
    final items = BackendCompat.extractList(response.data);
    final result = <Outfit>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      // Backend returns FavoriteOutfit with populated outfitId field
      final outfitData = item['outfitId'];
      final Map<String, dynamic> data =
          outfitData is Map<String, dynamic> ? outfitData : item;
      try {
        result.add(_normalizeOutfit({...data, 'isFavorite': true}));
      } catch (_) {}
    }
    return result;
  }

  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.outfitHistory,
      queryParameters: {'page': page, 'limit': limit},
    );
    return BackendCompat.extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(_normalizeOutfit)
        .toList();
  }

  Future<ShareCardResult> generateShareCard(String outfitId) async {
    final response = await _dio.post(Endpoints.shareCard(outfitId));
    final data = BackendCompat.extractMap(response.data);
    return ShareCardResult.fromJson(data);
  }
}
