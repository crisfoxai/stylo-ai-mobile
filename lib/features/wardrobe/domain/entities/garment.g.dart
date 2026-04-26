// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GarmentImpl _$$GarmentImplFromJson(Map<String, dynamic> json) =>
    _$GarmentImpl(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String,
      color: json['color'] as String?,
      style: json['style'] as String?,
      material: json['material'] as String?,
      season: json['season'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      userId: json['userId'] as String,
      confidences: (json['confidences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      status:
          $enumDecodeNullable(_$ItemStatusEnumMap, json['status']) ??
          ItemStatus.ready,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$GarmentImplToJson(_$GarmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'type': instance.type,
      'color': instance.color,
      'style': instance.style,
      'material': instance.material,
      'season': instance.season,
      'tags': instance.tags,
      'userId': instance.userId,
      'confidences': instance.confidences,
      'status': _$ItemStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ItemStatusEnumMap = {
  ItemStatus.processing: 'processing',
  ItemStatus.ready: 'ready',
  ItemStatus.failed: 'failed',
};
