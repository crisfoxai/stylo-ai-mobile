import 'package:freezed_annotation/freezed_annotation.dart';

part 'detection_result.freezed.dart';
part 'detection_result.g.dart';

@freezed
class DetectionResult with _$DetectionResult {
  const factory DetectionResult({
    required List<DetectedGarment> detected,
    required String photoKey,
  }) = _DetectionResult;

  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      _$DetectionResultFromJson(json);
}

@freezed
class DetectedGarment with _$DetectedGarment {
  const factory DetectedGarment({
    required String tipo,
    required String color,
    required String descripcion,
    required String categoria,
    String? material,
    String? fit,
  }) = _DetectedGarment;

  factory DetectedGarment.fromJson(Map<String, dynamic> json) =>
      _$DetectedGarmentFromJson(json);
}

/// Mutable copy of DetectedGarment used for editing before confirm.
class DetectedGarmentEdit {
  String tipo;
  String color;
  String descripcion;
  String categoria;
  String? material;
  String? fit;
  bool include;

  DetectedGarmentEdit.fromDetected(DetectedGarment g)
      : tipo = g.tipo,
        color = g.color,
        descripcion = g.descripcion,
        categoria = g.categoria,
        material = g.material,
        fit = g.fit,
        include = true;

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'color': color,
        'descripcion': descripcion,
        'categoria': categoria,
        if (material != null && material!.isNotEmpty) 'material': material,
        if (fit != null && fit!.isNotEmpty) 'fit': fit,
      };
}
