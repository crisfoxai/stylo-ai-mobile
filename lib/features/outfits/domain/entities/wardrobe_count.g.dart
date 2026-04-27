// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WardrobeCountImpl _$$WardrobeCountImplFromJson(Map<String, dynamic> json) =>
    _$WardrobeCountImpl(
      count: (json['count'] as num).toInt(),
      threshold: (json['threshold'] as num).toInt(),
      state: json['state'] as String,
    );

Map<String, dynamic> _$$WardrobeCountImplToJson(_$WardrobeCountImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'threshold': instance.threshold,
      'state': instance.state,
    };
