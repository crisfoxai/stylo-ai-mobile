import '../../domain/entities/garment.dart';

class GarmentModel extends Garment {
  const GarmentModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.thumbnailUrl,
    required super.type,
    super.color,
    super.style,
    super.material,
    super.season,
    super.tags,
    required super.userId,
    super.confidences,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GarmentModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? confidences;
    if (json['confidences'] != null) {
      final raw = json['confidences'] as Map<String, dynamic>;
      confidences = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    return GarmentModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String? ?? '',
      color: json['color'] as String?,
      style: json['style'] as String?,
      material: json['material'] as String?,
      season: json['season'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      userId: json['userId'] as String? ?? '',
      confidences: confidences,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'type': type,
        'color': color,
        'style': style,
        'material': material,
        'season': season,
        'tags': tags,
        'userId': userId,
        'confidences': confidences,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
