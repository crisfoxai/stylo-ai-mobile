// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StyleProfileImpl _$$StyleProfileImplFromJson(Map<String, dynamic> json) =>
    _$StyleProfileImpl(
      id: json['id'] as String,
      aesthetics:
          (json['aesthetics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteColors:
          (json['favoriteColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      occasions:
          (json['occasions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      adventureLevel: json['adventureLevel'] as String? ?? '',
      priorities:
          (json['priorities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      styleBadge: json['styleBadge'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StyleProfileImplToJson(_$StyleProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aesthetics': instance.aesthetics,
      'favoriteColors': instance.favoriteColors,
      'occasions': instance.occasions,
      'adventureLevel': instance.adventureLevel,
      'priorities': instance.priorities,
      'styleBadge': instance.styleBadge,
      'createdAt': instance.createdAt.toIso8601String(),
    };
