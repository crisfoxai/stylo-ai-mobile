import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_profile.freezed.dart';
part 'style_profile.g.dart';

@freezed
class StyleProfile with _$StyleProfile {
  const factory StyleProfile({
    required String id,
    @Default([]) List<String> aesthetics,
    @Default([]) List<String> favoriteColors,
    @Default([]) List<String> occasions,
    @Default('') String adventureLevel,
    @Default([]) List<String> priorities,
    String? styleBadge,
    required DateTime createdAt,
  }) = _StyleProfile;

  factory StyleProfile.fromJson(Map<String, dynamic> json) =>
      _$StyleProfileFromJson(json);
}
