// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detection_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) {
  return _DetectionResult.fromJson(json);
}

/// @nodoc
mixin _$DetectionResult {
  List<DetectedGarment> get detected => throw _privateConstructorUsedError;
  String get photoKey => throw _privateConstructorUsedError;

  /// Serializes this DetectionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectionResultCopyWith<DetectionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectionResultCopyWith<$Res> {
  factory $DetectionResultCopyWith(
    DetectionResult value,
    $Res Function(DetectionResult) then,
  ) = _$DetectionResultCopyWithImpl<$Res, DetectionResult>;
  @useResult
  $Res call({List<DetectedGarment> detected, String photoKey});
}

/// @nodoc
class _$DetectionResultCopyWithImpl<$Res, $Val extends DetectionResult>
    implements $DetectionResultCopyWith<$Res> {
  _$DetectionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? detected = null, Object? photoKey = null}) {
    return _then(
      _value.copyWith(
            detected: null == detected
                ? _value.detected
                : detected // ignore: cast_nullable_to_non_nullable
                      as List<DetectedGarment>,
            photoKey: null == photoKey
                ? _value.photoKey
                : photoKey // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DetectionResultImplCopyWith<$Res>
    implements $DetectionResultCopyWith<$Res> {
  factory _$$DetectionResultImplCopyWith(
    _$DetectionResultImpl value,
    $Res Function(_$DetectionResultImpl) then,
  ) = __$$DetectionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DetectedGarment> detected, String photoKey});
}

/// @nodoc
class __$$DetectionResultImplCopyWithImpl<$Res>
    extends _$DetectionResultCopyWithImpl<$Res, _$DetectionResultImpl>
    implements _$$DetectionResultImplCopyWith<$Res> {
  __$$DetectionResultImplCopyWithImpl(
    _$DetectionResultImpl _value,
    $Res Function(_$DetectionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? detected = null, Object? photoKey = null}) {
    return _then(
      _$DetectionResultImpl(
        detected: null == detected
            ? _value._detected
            : detected // ignore: cast_nullable_to_non_nullable
                  as List<DetectedGarment>,
        photoKey: null == photoKey
            ? _value.photoKey
            : photoKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectionResultImpl implements _DetectionResult {
  const _$DetectionResultImpl({
    required final List<DetectedGarment> detected,
    required this.photoKey,
  }) : _detected = detected;

  factory _$DetectionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectionResultImplFromJson(json);

  final List<DetectedGarment> _detected;
  @override
  List<DetectedGarment> get detected {
    if (_detected is EqualUnmodifiableListView) return _detected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detected);
  }

  @override
  final String photoKey;

  @override
  String toString() {
    return 'DetectionResult(detected: $detected, photoKey: $photoKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectionResultImpl &&
            const DeepCollectionEquality().equals(other._detected, _detected) &&
            (identical(other.photoKey, photoKey) ||
                other.photoKey == photoKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_detected),
    photoKey,
  );

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectionResultImplCopyWith<_$DetectionResultImpl> get copyWith =>
      __$$DetectionResultImplCopyWithImpl<_$DetectionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectionResultImplToJson(this);
  }
}

abstract class _DetectionResult implements DetectionResult {
  const factory _DetectionResult({
    required final List<DetectedGarment> detected,
    required final String photoKey,
  }) = _$DetectionResultImpl;

  factory _DetectionResult.fromJson(Map<String, dynamic> json) =
      _$DetectionResultImpl.fromJson;

  @override
  List<DetectedGarment> get detected;
  @override
  String get photoKey;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectionResultImplCopyWith<_$DetectionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DetectedGarment _$DetectedGarmentFromJson(Map<String, dynamic> json) {
  return _DetectedGarment.fromJson(json);
}

/// @nodoc
mixin _$DetectedGarment {
  String get tipo => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  String get categoria => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get fit => throw _privateConstructorUsedError;

  /// Serializes this DetectedGarment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectedGarment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectedGarmentCopyWith<DetectedGarment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectedGarmentCopyWith<$Res> {
  factory $DetectedGarmentCopyWith(
    DetectedGarment value,
    $Res Function(DetectedGarment) then,
  ) = _$DetectedGarmentCopyWithImpl<$Res, DetectedGarment>;
  @useResult
  $Res call({
    String tipo,
    String color,
    String descripcion,
    String categoria,
    String? material,
    String? fit,
  });
}

/// @nodoc
class _$DetectedGarmentCopyWithImpl<$Res, $Val extends DetectedGarment>
    implements $DetectedGarmentCopyWith<$Res> {
  _$DetectedGarmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectedGarment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tipo = null,
    Object? color = null,
    Object? descripcion = null,
    Object? categoria = null,
    Object? material = freezed,
    Object? fit = freezed,
  }) {
    return _then(
      _value.copyWith(
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            categoria: null == categoria
                ? _value.categoria
                : categoria // ignore: cast_nullable_to_non_nullable
                      as String,
            material: freezed == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String?,
            fit: freezed == fit
                ? _value.fit
                : fit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DetectedGarmentImplCopyWith<$Res>
    implements $DetectedGarmentCopyWith<$Res> {
  factory _$$DetectedGarmentImplCopyWith(
    _$DetectedGarmentImpl value,
    $Res Function(_$DetectedGarmentImpl) then,
  ) = __$$DetectedGarmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String tipo,
    String color,
    String descripcion,
    String categoria,
    String? material,
    String? fit,
  });
}

/// @nodoc
class __$$DetectedGarmentImplCopyWithImpl<$Res>
    extends _$DetectedGarmentCopyWithImpl<$Res, _$DetectedGarmentImpl>
    implements _$$DetectedGarmentImplCopyWith<$Res> {
  __$$DetectedGarmentImplCopyWithImpl(
    _$DetectedGarmentImpl _value,
    $Res Function(_$DetectedGarmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DetectedGarment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tipo = null,
    Object? color = null,
    Object? descripcion = null,
    Object? categoria = null,
    Object? material = freezed,
    Object? fit = freezed,
  }) {
    return _then(
      _$DetectedGarmentImpl(
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        categoria: null == categoria
            ? _value.categoria
            : categoria // ignore: cast_nullable_to_non_nullable
                  as String,
        material: freezed == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String?,
        fit: freezed == fit
            ? _value.fit
            : fit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectedGarmentImpl implements _DetectedGarment {
  const _$DetectedGarmentImpl({
    required this.tipo,
    required this.color,
    required this.descripcion,
    required this.categoria,
    this.material,
    this.fit,
  });

  factory _$DetectedGarmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectedGarmentImplFromJson(json);

  @override
  final String tipo;
  @override
  final String color;
  @override
  final String descripcion;
  @override
  final String categoria;
  @override
  final String? material;
  @override
  final String? fit;

  @override
  String toString() {
    return 'DetectedGarment(tipo: $tipo, color: $color, descripcion: $descripcion, categoria: $categoria, material: $material, fit: $fit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectedGarmentImpl &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.categoria, categoria) ||
                other.categoria == categoria) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.fit, fit) || other.fit == fit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tipo,
    color,
    descripcion,
    categoria,
    material,
    fit,
  );

  /// Create a copy of DetectedGarment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectedGarmentImplCopyWith<_$DetectedGarmentImpl> get copyWith =>
      __$$DetectedGarmentImplCopyWithImpl<_$DetectedGarmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectedGarmentImplToJson(this);
  }
}

abstract class _DetectedGarment implements DetectedGarment {
  const factory _DetectedGarment({
    required final String tipo,
    required final String color,
    required final String descripcion,
    required final String categoria,
    final String? material,
    final String? fit,
  }) = _$DetectedGarmentImpl;

  factory _DetectedGarment.fromJson(Map<String, dynamic> json) =
      _$DetectedGarmentImpl.fromJson;

  @override
  String get tipo;
  @override
  String get color;
  @override
  String get descripcion;
  @override
  String get categoria;
  @override
  String? get material;
  @override
  String? get fit;

  /// Create a copy of DetectedGarment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectedGarmentImplCopyWith<_$DetectedGarmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
