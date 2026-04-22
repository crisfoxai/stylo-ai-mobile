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
    @Default(false) bool isFavorite,
    DateTime? wornAt,
    required DateTime createdAt,
  }) = _Outfit;

  factory Outfit.fromJson(Map<String, dynamic> json) =>
      _$OutfitFromJson(json);
}
