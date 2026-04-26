// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Garment _$GarmentFromJson(Map<String, dynamic> json) {
  return _Garment.fromJson(json);
}

/// @nodoc
mixin _$Garment {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get style => throw _privateConstructorUsedError;
  String? get material => throw _privateConstructorUsedError;
  String? get season => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, double>? get confidences => throw _privateConstructorUsedError;
  ItemStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Garment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Garment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GarmentCopyWith<Garment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GarmentCopyWith<$Res> {
  factory $GarmentCopyWith(Garment value, $Res Function(Garment) then) =
      _$GarmentCopyWithImpl<$Res, Garment>;
  @useResult
  $Res call({
    String id,
    String name,
    String imageUrl,
    String? thumbnailUrl,
    String type,
    String? category,
    String? color,
    String? style,
    String? material,
    String? season,
    List<String> tags,
    String userId,
    Map<String, double>? confidences,
    ItemStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$GarmentCopyWithImpl<$Res, $Val extends Garment>
    implements $GarmentCopyWith<$Res> {
  _$GarmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Garment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? type = null,
    Object? category = freezed,
    Object? color = freezed,
    Object? style = freezed,
    Object? material = freezed,
    Object? season = freezed,
    Object? tags = null,
    Object? userId = null,
    Object? confidences = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            style: freezed == style
                ? _value.style
                : style // ignore: cast_nullable_to_non_nullable
                      as String?,
            material: freezed == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String?,
            season: freezed == season
                ? _value.season
                : season // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            confidences: freezed == confidences
                ? _value.confidences
                : confidences // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ItemStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GarmentImplCopyWith<$Res> implements $GarmentCopyWith<$Res> {
  factory _$$GarmentImplCopyWith(
    _$GarmentImpl value,
    $Res Function(_$GarmentImpl) then,
  ) = __$$GarmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String imageUrl,
    String? thumbnailUrl,
    String type,
    String? category,
    String? color,
    String? style,
    String? material,
    String? season,
    List<String> tags,
    String userId,
    Map<String, double>? confidences,
    ItemStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$GarmentImplCopyWithImpl<$Res>
    extends _$GarmentCopyWithImpl<$Res, _$GarmentImpl>
    implements _$$GarmentImplCopyWith<$Res> {
  __$$GarmentImplCopyWithImpl(
    _$GarmentImpl _value,
    $Res Function(_$GarmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Garment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? type = null,
    Object? category = freezed,
    Object? color = freezed,
    Object? style = freezed,
    Object? material = freezed,
    Object? season = freezed,
    Object? tags = null,
    Object? userId = null,
    Object? confidences = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$GarmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        style: freezed == style
            ? _value.style
            : style // ignore: cast_nullable_to_non_nullable
                  as String?,
        material: freezed == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String?,
        season: freezed == season
            ? _value.season
            : season // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        confidences: freezed == confidences
            ? _value._confidences
            : confidences // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ItemStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GarmentImpl implements _Garment {
  const _$GarmentImpl({
    required this.id,
    this.name = '',
    required this.imageUrl,
    this.thumbnailUrl,
    required this.type,
    this.category,
    this.color,
    this.style,
    this.material,
    this.season,
    final List<String> tags = const [],
    required this.userId,
    final Map<String, double>? confidences,
    this.status = ItemStatus.ready,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags,
       _confidences = confidences;

  factory _$GarmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$GarmentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  final String imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String type;
  @override
  final String? category;
  @override
  final String? color;
  @override
  final String? style;
  @override
  final String? material;
  @override
  final String? season;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String userId;
  final Map<String, double>? _confidences;
  @override
  Map<String, double>? get confidences {
    final value = _confidences;
    if (value == null) return null;
    if (_confidences is EqualUnmodifiableMapView) return _confidences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final ItemStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Garment(id: $id, name: $name, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, type: $type, category: $category, color: $color, style: $style, material: $material, season: $season, tags: $tags, userId: $userId, confidences: $confidences, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GarmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.season, season) || other.season == season) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality().equals(
              other._confidences,
              _confidences,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    imageUrl,
    thumbnailUrl,
    type,
    category,
    color,
    style,
    material,
    season,
    const DeepCollectionEquality().hash(_tags),
    userId,
    const DeepCollectionEquality().hash(_confidences),
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Garment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GarmentImplCopyWith<_$GarmentImpl> get copyWith =>
      __$$GarmentImplCopyWithImpl<_$GarmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GarmentImplToJson(this);
  }
}

abstract class _Garment implements Garment {
  const factory _Garment({
    required final String id,
    final String name,
    required final String imageUrl,
    final String? thumbnailUrl,
    required final String type,
    final String? category,
    final String? color,
    final String? style,
    final String? material,
    final String? season,
    final List<String> tags,
    required final String userId,
    final Map<String, double>? confidences,
    final ItemStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$GarmentImpl;

  factory _Garment.fromJson(Map<String, dynamic> json) = _$GarmentImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get imageUrl;
  @override
  String? get thumbnailUrl;
  @override
  String get type;
  @override
  String? get category;
  @override
  String? get color;
  @override
  String? get style;
  @override
  String? get material;
  @override
  String? get season;
  @override
  List<String> get tags;
  @override
  String get userId;
  @override
  Map<String, double>? get confidences;
  @override
  ItemStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Garment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GarmentImplCopyWith<_$GarmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
