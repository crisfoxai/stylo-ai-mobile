import 'package:freezed_annotation/freezed_annotation.dart';

part 'garment.freezed.dart';
part 'garment.g.dart';

enum ItemStatus { processing, ready, failed }

@freezed
class Garment with _$Garment {
  const factory Garment({
    required String id,
    @Default('') String name,
    required String imageUrl,
    String? thumbnailUrl,
    required String type,
    String? category,
    String? color,
    String? style,
    String? material,
    String? season,
    @Default([]) List<String> tags,
    required String userId,
    Map<String, double>? confidences,
    @Default(ItemStatus.ready) ItemStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Garment;

  factory Garment.fromJson(Map<String, dynamic> json) =>
      _$GarmentFromJson(json);
}
