// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OutfitGarmentImpl _$$OutfitGarmentImplFromJson(Map<String, dynamic> json) =>
    _$OutfitGarmentImpl(
      garmentId: json['garmentId'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String,
      color: json['color'] as String,
      style: json['style'] as String,
    );

Map<String, dynamic> _$$OutfitGarmentImplToJson(_$OutfitGarmentImpl instance) =>
    <String, dynamic>{
      'garmentId': instance.garmentId,
      'thumbnailUrl': instance.thumbnailUrl,
      'type': instance.type,
      'color': instance.color,
      'style': instance.style,
    };

_$OutfitImpl _$$OutfitImplFromJson(Map<String, dynamic> json) => _$OutfitImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  garments:
      (json['garments'] as List<dynamic>?)
          ?.map((e) => OutfitGarment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  mood: json['mood'] as String?,
  event: json['event'] as String?,
  occasion: json['occasion'] as String?,
  weatherContext: json['weatherContext'] as String?,
  score: (json['score'] as num?)?.toDouble(),
  rationale: json['rationale'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  wornAt: json['wornAt'] == null
      ? null
      : DateTime.parse(json['wornAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$OutfitImplToJson(_$OutfitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'garments': instance.garments,
      'mood': instance.mood,
      'event': instance.event,
      'occasion': instance.occasion,
      'weatherContext': instance.weatherContext,
      'score': instance.score,
      'rationale': instance.rationale,
      'isFavorite': instance.isFavorite,
      'wornAt': instance.wornAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
