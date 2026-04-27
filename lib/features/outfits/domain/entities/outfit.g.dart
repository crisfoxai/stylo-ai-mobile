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
  justification: json['justification'] as String?,
  contextFactors:
      (json['contextFactors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isFavorite: json['isFavorite'] as bool? ?? false,
  wornAt: json['wornAt'] == null
      ? null
      : DateTime.parse(json['wornAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  coverImageSource: json['coverImageSource'] as String? ?? 'placeholder',
  coverImageUrl: json['coverImageUrl'] as String?,
  tryonImageUrl: json['tryonImageUrl'] as String?,
  lookPhotoUrl: json['lookPhotoUrl'] as String?,
  hasLookPhoto: json['hasLookPhoto'] as bool? ?? false,
  usedAt: json['usedAt'] == null
      ? null
      : DateTime.parse(json['usedAt'] as String),
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
      'justification': instance.justification,
      'contextFactors': instance.contextFactors,
      'isFavorite': instance.isFavorite,
      'wornAt': instance.wornAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'coverImageSource': instance.coverImageSource,
      'coverImageUrl': instance.coverImageUrl,
      'tryonImageUrl': instance.tryonImageUrl,
      'lookPhotoUrl': instance.lookPhotoUrl,
      'hasLookPhoto': instance.hasLookPhoto,
      'usedAt': instance.usedAt?.toIso8601String(),
    };

_$OutfitsPageImpl _$$OutfitsPageImplFromJson(Map<String, dynamic> json) =>
    _$OutfitsPageImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => Outfit.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$$OutfitsPageImplToJson(_$OutfitsPageImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'totalPages': instance.totalPages,
    };
