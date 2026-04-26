import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/backend_compat.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/style_profile.dart';

class StyleProfileRemoteDataSource {
  final Dio _dio;

  StyleProfileRemoteDataSource(this._dio);

  Future<StyleProfile> getProfile() async {
    final response = await _dio.get(Endpoints.styleProfile);
    final raw = BackendCompat.extractMap(response.data);
    return StyleProfile.fromJson(_normalize(raw));
  }

  Future<StyleProfile> submitQuiz(Map<String, dynamic> answers) async {
    debugPrint('[STYLE] POST ${Endpoints.styleProfile}');
    try {
      final response = await _dio.post(Endpoints.styleProfile, data: answers);
      debugPrint('[STYLE] POST status=${response.statusCode}');
      final raw = BackendCompat.extractMap(response.data);
      return StyleProfile.fromJson(_normalize(raw));
    } on DioException catch (e) {
      debugPrint('[STYLE] DioException status=${e.response?.statusCode} err=${e.error}');
      // 409 Conflict: profile already exists — update instead
      if (e.response?.statusCode == 409) {
        final response = await _dio.patch(Endpoints.styleProfile, data: answers);
        debugPrint('[STYLE] PATCH status=${response.statusCode}');
        final raw = BackendCompat.extractMap(response.data);
        return StyleProfile.fromJson(_normalize(raw));
      }
      rethrow;
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    return {
      'id': (raw['_id'] ?? raw['id'] ?? '').toString(),
      // Local: styles / aesthetics  |  Railway: preferredStyles
      'aesthetics': (raw['preferredStyles'] as List?)?.cast<String>()
          ?? (raw['styles'] as List?)?.cast<String>()
          ?? (raw['aesthetics'] as List?)?.cast<String>()
          ?? [],
      // Local: colors / favoriteColors  |  Railway: preferredColors
      'favoriteColors': (raw['preferredColors'] as List?)?.cast<String>()
          ?? (raw['colors'] as List?)?.cast<String>()
          ?? (raw['favoriteColors'] as List?)?.cast<String>()
          ?? [],
      // Local: occasions  |  Railway: commonOccasions
      'occasions': (raw['commonOccasions'] as List?)?.cast<String>()
          ?? (raw['occasions'] as List?)?.cast<String>()
          ?? [],
      'adventureLevel': raw['adventureLevel']?.toString() ?? '',
      'priorities': (raw['priorities'] as List?)?.cast<String>() ?? [],
      'styleBadge': raw['styleBadge'] as String?,
      'createdAt': raw['createdAt']?.toString()
          ?? raw['updatedAt']?.toString()
          ?? DateTime.now().toIso8601String(),
    };
  }
}
