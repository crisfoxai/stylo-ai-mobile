import '../../domain/entities/style_profile.dart';

class StyleProfileModel extends StyleProfile {
  const StyleProfileModel({
    required super.id,
    required super.aesthetics,
    required super.favoriteColors,
    required super.occasions,
    required super.adventureLevel,
    required super.priorities,
    super.styleBadge,
    required super.createdAt,
  });

  factory StyleProfileModel.fromJson(Map<String, dynamic> json) {
    return StyleProfileModel(
      id: json['id'] as String,
      aesthetics: (json['aesthetics'] as List).cast<String>(),
      favoriteColors: (json['favoriteColors'] as List).cast<String>(),
      occasions: (json['occasions'] as List).cast<String>(),
      adventureLevel: json['adventureLevel'] as String? ?? '',
      priorities: (json['priorities'] as List?)?.cast<String>() ?? [],
      styleBadge: json['styleBadge'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'aesthetics': aesthetics,
    'favoriteColors': favoriteColors,
    'occasions': occasions,
    'adventureLevel': adventureLevel,
    'priorities': priorities,
  };
}
