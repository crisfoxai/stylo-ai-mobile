import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit.freezed.dart';
part 'outfit.g.dart';

@freezed
class OutfitGarment with _$OutfitGarment {
  const factory OutfitGarment({
    required String garmentId,
    String? thumbnailUrl,
    required String type,
    required String color,
    required String style,
  }) = _OutfitGarment;

  factory OutfitGarment.fromJson(Map<String, dynamic> json) =>
      _$OutfitGarmentFromJson(json);
}

@freezed
class Outfit with _$Outfit {
  const factory Outfit({
    required String id,
    required String name,
    @Default([]) List<OutfitGarment> garments,
    String? mood,
    String? event,
    String? occasion,
    String? weatherContext,
    double? score,
    String? rationale,
    String? justification,
    @Default([]) List<String> contextFactors,
    @Default(false) bool isFavorite,
    DateTime? wornAt,
    required DateTime createdAt,
    // v4 fields
    @Default('placeholder') String coverImageSource,
    String? coverImageUrl,
    String? tryonImageUrl,
    String? lookPhotoUrl,
    @Default(false) bool hasLookPhoto,
    DateTime? usedAt,
  }) = _Outfit;

  factory Outfit.fromJson(Map<String, dynamic> json) =>
      _$OutfitFromJson(json);
}

@freezed
class OutfitsPage with _$OutfitsPage {
  const factory OutfitsPage({
    required List<Outfit> data,
    required int total,
    required int page,
    required int totalPages,
  }) = _OutfitsPage;

  factory OutfitsPage.fromJson(Map<String, dynamic> json) =>
      _$OutfitsPageFromJson(json);
}
