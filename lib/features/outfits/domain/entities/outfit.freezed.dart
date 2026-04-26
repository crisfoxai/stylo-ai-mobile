// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OutfitGarment _$OutfitGarmentFromJson(Map<String, dynamic> json) {
  return _OutfitGarment.fromJson(json);
}

/// @nodoc
mixin _$OutfitGarment {
  String get garmentId => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get style => throw _privateConstructorUsedError;

  /// Serializes this OutfitGarment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OutfitGarment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitGarmentCopyWith<OutfitGarment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitGarmentCopyWith<$Res> {
  factory $OutfitGarmentCopyWith(
    OutfitGarment value,
    $Res Function(OutfitGarment) then,
  ) = _$OutfitGarmentCopyWithImpl<$Res, OutfitGarment>;
  @useResult
  $Res call({
    String garmentId,
    String? thumbnailUrl,
    String type,
    String color,
    String style,
  });
}

/// @nodoc
class _$OutfitGarmentCopyWithImpl<$Res, $Val extends OutfitGarment>
    implements $OutfitGarmentCopyWith<$Res> {
  _$OutfitGarmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitGarment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? garmentId = null,
    Object? thumbnailUrl = freezed,
    Object? type = null,
    Object? color = null,
    Object? style = null,
  }) {
    return _then(
      _value.copyWith(
            garmentId: null == garmentId
                ? _value.garmentId
                : garmentId // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            style: null == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OutfitGarmentImplCopyWith<$Res>
    implements $OutfitGarmentCopyWith<$Res> {
  factory _$$OutfitGarmentImplCopyWith(
    _$OutfitGarmentImpl value,
    $Res Function(_$OutfitGarmentImpl) then,
  ) = __$$OutfitGarmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String garmentId,
    String? thumbnailUrl,
    String type,
    String color,
    String style,
  });
}

/// @nodoc
class __$$OutfitGarmentImplCopyWithImpl<$Res>
    extends _$OutfitGarmentCopyWithImpl<$Res, _$OutfitGarmentImpl>
    implements _$$OutfitGarmentImplCopyWith<$Res> {
  __$$OutfitGarmentImplCopyWithImpl(
    _$OutfitGarmentImpl _value,
    $Res Function(_$OutfitGarmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OutfitGarment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? garmentId = null,
    Object? thumbnailUrl = freezed,
    Object? type = null,
    Object? color = null,
    Object? style = null,
  }) {
    return _then(
      _$OutfitGarmentImpl(
        garmentId: null == garmentId
            ? _value.garmentId
            : garmentId // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        style: null == style
            ? _value.style
            : style // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitGarmentImpl implements _OutfitGarment {
  const _$OutfitGarmentImpl({
    required this.garmentId,
    this.thumbnailUrl,
    required this.type,
    required this.color,
    required this.style,
  });

  factory _$OutfitGarmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitGarmentImplFromJson(json);

  @override
  final String garmentId;
  @override
  final String? thumbnailUrl;
  @override
  final String type;
  @override
  final String color;
  @override
  final String style;

  @override
  String toString() {
    return 'OutfitGarment(garmentId: $garmentId, thumbnailUrl: $thumbnailUrl, type: $type, color: $color, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitGarmentImpl &&
            (identical(other.garmentId, garmentId) ||
                other.garmentId == garmentId) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.style, style) || other.style == style));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, garmentId, thumbnailUrl, type, color, style);

  /// Create a copy of OutfitGarment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitGarmentImplCopyWith<_$OutfitGarmentImpl> get copyWith =>
      __$$OutfitGarmentImplCopyWithImpl<_$OutfitGarmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitGarmentImplToJson(this);
  }
}

abstract class _OutfitGarment implements OutfitGarment {
  const factory _OutfitGarment({
    required final String garmentId,
    final String? thumbnailUrl,
    required final String type,
    required final String color,
    required final String style,
  }) = _$OutfitGarmentImpl;

  factory _OutfitGarment.fromJson(Map<String, dynamic> json) =
      _$OutfitGarmentImpl.fromJson;

  @override
  String get garmentId;
  @override
  String? get thumbnailUrl;
  @override
  String get type;
  @override
  String get color;
  @override
  String get style;

  /// Create a copy of OutfitGarment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitGarmentImplCopyWith<_$OutfitGarmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Outfit _$OutfitFromJson(Map<String, dynamic> json) {
  return _Outfit.fromJson(json);
}

/// @nodoc
mixin _$Outfit {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<OutfitGarment> get garments => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get event => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  String? get weatherContext => throw _privateConstructorUsedError;
  double? get score => throw _privateConstructorUsedError;
  String? get rationale => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  DateTime? get wornAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Outfit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitCopyWith<Outfit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitCopyWith<$Res> {
  factory $OutfitCopyWith(Outfit value, $Res Function(Outfit) then) =
      _$OutfitCopyWithImpl<$Res, Outfit>;
  @useResult
  $Res call({
    String id,
    String name,
    List<OutfitGarment> garments,
    String? mood,
    String? event,
    String? occasion,
    String? weatherContext,
    double? score,
    String? rationale,
    bool isFavorite,
    DateTime? wornAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$OutfitCopyWithImpl<$Res, $Val extends Outfit>
    implements $OutfitCopyWith<$Res> {
  _$OutfitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? garments = null,
    Object? mood = freezed,
    Object? event = freezed,
    Object? occasion = freezed,
    Object? weatherContext = freezed,
    Object? score = freezed,
    Object? rationale = freezed,
    Object? isFavorite = null,
    Object? wornAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            garments: null == garments
                ? _value.garments
                : garments // ignore: cast_nullable_to_non_nullable
                      as List<OutfitGarment>,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            event: freezed == event
                ? _value.event
                : event // ignore: cast_nullable_to_non_nullable
                      as String?,
            occasion: freezed == occasion
                ? _value.occasion
                : occasion // ignore: cast_nullable_to_non_nullable
                      as String?,
            weatherContext: freezed == weatherContext
                ? _value.weatherContext
                : weatherContext // ignore: cast_nullable_to_non_nullable
                      as String?,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double?,
            rationale: freezed == rationale
                ? _value.rationale
                : rationale // ignore: cast_nullable_to_non_nullable
                      as String?,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            wornAt: freezed == wornAt
                ? _value.wornAt
                : wornAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OutfitImplCopyWith<$Res> implements $OutfitCopyWith<$Res> {
  factory _$$OutfitImplCopyWith(
    _$OutfitImpl value,
    $Res Function(_$OutfitImpl) then,
  ) = __$$OutfitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<OutfitGarment> garments,
    String? mood,
    String? event,
    String? occasion,
    String? weatherContext,
    double? score,
    String? rationale,
    bool isFavorite,
    DateTime? wornAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$OutfitImplCopyWithImpl<$Res>
    extends _$OutfitCopyWithImpl<$Res, _$OutfitImpl>
    implements _$$OutfitImplCopyWith<$Res> {
  __$$OutfitImplCopyWithImpl(
    _$OutfitImpl _value,
    $Res Function(_$OutfitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? garments = null,
    Object? mood = freezed,
    Object? event = freezed,
    Object? occasion = freezed,
    Object? weatherContext = freezed,
    Object? score = freezed,
    Object? rationale = freezed,
    Object? isFavorite = null,
    Object? wornAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$OutfitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        garments: null == garments
            ? _value._garments
            : garments // ignore: cast_nullable_to_non_nullable
                  as List<OutfitGarment>,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        event: freezed == event
            ? _value.event
            : event // ignore: cast_nullable_to_non_nullable
                  as String?,
        occasion: freezed == occasion
            ? _value.occasion
            : occasion // ignore: cast_nullable_to_non_nullable
                  as String?,
        weatherContext: freezed == weatherContext
            ? _value.weatherContext
            : weatherContext // ignore: cast_nullable_to_non_nullable
                  as String?,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double?,
        rationale: freezed == rationale
            ? _value.rationale
            : rationale // ignore: cast_nullable_to_non_nullable
                  as String?,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        wornAt: freezed == wornAt
            ? _value.wornAt
            : wornAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfitImpl implements _Outfit {
  const _$OutfitImpl({
    required this.id,
    required this.name,
    final List<OutfitGarment> garments = const [],
    this.mood,
    this.event,
    this.occasion,
    this.weatherContext,
    this.score,
    this.rationale,
    this.isFavorite = false,
    this.wornAt,
    required this.createdAt,
  }) : _garments = garments;

  factory _$OutfitImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfitImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<OutfitGarment> _garments;
  @override
  @JsonKey()
  List<OutfitGarment> get garments {
    if (_garments is EqualUnmodifiableListView) return _garments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_garments);
  }

  @override
  final String? mood;
  @override
  final String? event;
  @override
  final String? occasion;
  @override
  final String? weatherContext;
  @override
  final double? score;
  @override
  final String? rationale;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final DateTime? wornAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Outfit(id: $id, name: $name, garments: $garments, mood: $mood, event: $event, occasion: $occasion, weatherContext: $weatherContext, score: $score, rationale: $rationale, isFavorite: $isFavorite, wornAt: $wornAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._garments, _garments) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.event, event) || other.event == event) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            (identical(other.weatherContext, weatherContext) ||
                other.weatherContext == weatherContext) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.rationale, rationale) ||
                other.rationale == rationale) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.wornAt, wornAt) || other.wornAt == wornAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_garments),
    mood,
    event,
    occasion,
    weatherContext,
    score,
    rationale,
    isFavorite,
    wornAt,
    createdAt,
  );

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitImplCopyWith<_$OutfitImpl> get copyWith =>
      __$$OutfitImplCopyWithImpl<_$OutfitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfitImplToJson(this);
  }
}

abstract class _Outfit implements Outfit {
  const factory _Outfit({
    required final String id,
    required final String name,
    final List<OutfitGarment> garments,
    final String? mood,
    final String? event,
    final String? occasion,
    final String? weatherContext,
    final double? score,
    final String? rationale,
    final bool isFavorite,
    final DateTime? wornAt,
    required final DateTime createdAt,
  }) = _$OutfitImpl;

  factory _Outfit.fromJson(Map<String, dynamic> json) = _$OutfitImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<OutfitGarment> get garments;
  @override
  String? get mood;
  @override
  String? get event;
  @override
  String? get occasion;
  @override
  String? get weatherContext;
  @override
  double? get score;
  @override
  String? get rationale;
  @override
  bool get isFavorite;
  @override
  DateTime? get wornAt;
  @override
  DateTime get createdAt;

  /// Create a copy of Outfit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitImplCopyWith<_$OutfitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
