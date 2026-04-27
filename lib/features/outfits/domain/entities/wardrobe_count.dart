import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_count.freezed.dart';
part 'wardrobe_count.g.dart';

@freezed
class WardrobeCount with _$WardrobeCount {
  const factory WardrobeCount({
    required int count,
    required int threshold,
    required String state, // 'empty' | 'warning' | 'ready'
  }) = _WardrobeCount;

  factory WardrobeCount.fromJson(Map<String, dynamic> json) =>
      _$WardrobeCountFromJson(json);
}
