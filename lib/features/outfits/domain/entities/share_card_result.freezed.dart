// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'share_card_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShareCardResult _$ShareCardResultFromJson(Map<String, dynamic> json) {
  return _ShareCardResult.fromJson(json);
}

/// @nodoc
mixin _$ShareCardResult {
  String get url => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  String get outfitId => throw _privateConstructorUsedError;

  /// Serializes this ShareCardResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShareCardResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShareCardResultCopyWith<ShareCardResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareCardResultCopyWith<$Res> {
  factory $ShareCardResultCopyWith(
    ShareCardResult value,
    $Res Function(ShareCardResult) then,
  ) = _$ShareCardResultCopyWithImpl<$Res, ShareCardResult>;
  @useResult
  $Res call({String url, String expiresAt, String outfitId});
}

/// @nodoc
class _$ShareCardResultCopyWithImpl<$Res, $Val extends ShareCardResult>
    implements $ShareCardResultCopyWith<$Res> {
  _$ShareCardResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShareCardResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? expiresAt = null,
    Object? outfitId = null,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String,
            outfitId: null == outfitId
                ? _value.outfitId
                : outfitId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShareCardResultImplCopyWith<$Res>
    implements $ShareCardResultCopyWith<$Res> {
  factory _$$ShareCardResultImplCopyWith(
    _$ShareCardResultImpl value,
    $Res Function(_$ShareCardResultImpl) then,
  ) = __$$ShareCardResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String expiresAt, String outfitId});
}

/// @nodoc
class __$$ShareCardResultImplCopyWithImpl<$Res>
    extends _$ShareCardResultCopyWithImpl<$Res, _$ShareCardResultImpl>
    implements _$$ShareCardResultImplCopyWith<$Res> {
  __$$ShareCardResultImplCopyWithImpl(
    _$ShareCardResultImpl _value,
    $Res Function(_$ShareCardResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShareCardResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? expiresAt = null,
    Object? outfitId = null,
  }) {
    return _then(
      _$ShareCardResultImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String,
        outfitId: null == outfitId
            ? _value.outfitId
            : outfitId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareCardResultImpl implements _ShareCardResult {
  const _$ShareCardResultImpl({
    required this.url,
    required this.expiresAt,
    required this.outfitId,
  });

  factory _$ShareCardResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareCardResultImplFromJson(json);

  @override
  final String url;
  @override
  final String expiresAt;
  @override
  final String outfitId;

  @override
  String toString() {
    return 'ShareCardResult(url: $url, expiresAt: $expiresAt, outfitId: $outfitId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareCardResultImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.outfitId, outfitId) ||
                other.outfitId == outfitId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, expiresAt, outfitId);

  /// Create a copy of ShareCardResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareCardResultImplCopyWith<_$ShareCardResultImpl> get copyWith =>
      __$$ShareCardResultImplCopyWithImpl<_$ShareCardResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareCardResultImplToJson(this);
  }
}

abstract class _ShareCardResult implements ShareCardResult {
  const factory _ShareCardResult({
    required final String url,
    required final String expiresAt,
    required final String outfitId,
  }) = _$ShareCardResultImpl;

  factory _ShareCardResult.fromJson(Map<String, dynamic> json) =
      _$ShareCardResultImpl.fromJson;

  @override
  String get url;
  @override
  String get expiresAt;
  @override
  String get outfitId;

  /// Create a copy of ShareCardResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShareCardResultImplCopyWith<_$ShareCardResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
