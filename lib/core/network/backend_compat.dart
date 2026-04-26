/// Helpers to handle response format differences between backend versions.
///
/// Local (Docker) backend:
///   - Wraps responses in { success, data, error, meta }
///   - Auth: POST /auth/firebase
///   - Garments: /wardrobe
///
/// Railway backend:
///   - Returns data directly (no wrapper)
///   - Auth: POST /auth/session with Firebase ID token as Bearer
///   - Garments: /garments with { items, total, page }
class BackendCompat {
  BackendCompat._();

  /// Returns the unwrapped data map from a response body.
  /// Handles both { success, data: {…}, meta } (local) and direct map (Railway).
  static Map<String, dynamic> extractMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('success')) {
        return responseData['data'] as Map<String, dynamic>? ?? responseData;
      }
      return responseData;
    }
    return {};
  }

  /// Returns the unwrapped list from a response body.
  /// Handles:
  ///  - { success, data: […], meta }  → local
  ///  - […]                           → Railway direct array
  ///  - { items: […], … }             → Railway garments pagination
  static List<dynamic> extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('success') && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData.containsKey('items') && responseData['items'] is List) {
        return responseData['items'] as List;
      }
      if (responseData.containsKey('data') && responseData['data'] is List) {
        return responseData['data'] as List;
      }
    }
    return [];
  }

  /// Normalizes MongoDB `_id` → `id` so Garment.fromJson always finds `id`.
  static Map<String, dynamic> normalizeMongoId(Map<String, dynamic> map) {
    if (!map.containsKey('id') || map['id'] == null) {
      final mongoId = map['_id'];
      if (mongoId != null) {
        return {...map, 'id': mongoId};
      }
    }
    return map;
  }

  /// Returns the total count for paginated responses.
  static int extractTotal(dynamic responseData, int fallback) {
    if (responseData is Map<String, dynamic>) {
      final total = responseData['total'] ?? responseData['meta']?['total'];
      if (total is int) return total;
      if (total is num) return total.toInt();
    }
    return fallback;
  }
}
