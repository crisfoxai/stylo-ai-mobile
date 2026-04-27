// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetectionResultImpl _$$DetectionResultImplFromJson(
  Map<String, dynamic> json,
) => _$DetectionResultImpl(
  detected: (json['detected'] as List<dynamic>)
      .map((e) => DetectedGarment.fromJson(e as Map<String, dynamic>))
      .toList(),
  photoKey: json['photoKey'] as String,
);

Map<String, dynamic> _$$DetectionResultImplToJson(
  _$DetectionResultImpl instance,
) => <String, dynamic>{
  'detected': instance.detected,
  'photoKey': instance.photoKey,
};

_$DetectedGarmentImpl _$$DetectedGarmentImplFromJson(
  Map<String, dynamic> json,
) => _$DetectedGarmentImpl(
  tipo: json['tipo'] as String,
  color: json['color'] as String,
  descripcion: json['descripcion'] as String,
  categoria: json['categoria'] as String,
  material: json['material'] as String?,
  fit: json['fit'] as String?,
);

Map<String, dynamic> _$$DetectedGarmentImplToJson(
  _$DetectedGarmentImpl instance,
) => <String, dynamic>{
  'tipo': instance.tipo,
  'color': instance.color,
  'descripcion': instance.descripcion,
  'categoria': instance.categoria,
  'material': instance.material,
  'fit': instance.fit,
};
