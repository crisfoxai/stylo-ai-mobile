import '../../domain/entities/outfit.dart';

class OutfitGarmentModel extends OutfitGarment {
  const OutfitGarmentModel({
    required super.garmentId,
    super.thumbnailUrl,
    required super.type,
    required super.color,
    required super.style,
  });

  factory OutfitGarmentModel.fromJson(Map<String, dynamic> json) {
    return OutfitGarmentModel(
      garmentId: json['garmentId'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String? ?? '',
      color: json['color'] as String? ?? '',
      style: json['style'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'garmentId': garmentId,
        'thumbnailUrl': thumbnailUrl,
        'type': type,
        'color': color,
        'style': style,
      };
}

class OutfitModel extends Outfit {
  const OutfitModel({
    required super.id,
    required super.name,
    required super.garments,
    super.mood,
    super.event,
    super.weatherContext,
    super.score,
    super.rationale,
    super.isFavorite,
    super.wornAt,
    required super.createdAt,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    final garmentsList = (json['garments'] as List<dynamic>? ?? [])
        .map((g) => OutfitGarmentModel.fromJson(g as Map<String, dynamic>))
        .toList();

    return OutfitModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Outfit',
      garments: garmentsList,
      mood: json['mood'] as String?,
      event: json['event'] as String?,
      weatherContext: json['weatherContext'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      rationale: json['rationale'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      wornAt: json['wornAt'] != null
          ? DateTime.parse(json['wornAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'garments': garments
            .map((g) => (g as OutfitGarmentModel).toJson())
            .toList(),
        'mood': mood,
        'event': event,
        'weatherContext': weatherContext,
        'score': score,
        'rationale': rationale,
        'isFavorite': isFavorite,
        'wornAt': wornAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
