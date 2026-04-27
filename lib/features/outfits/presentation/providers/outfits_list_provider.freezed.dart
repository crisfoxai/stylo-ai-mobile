// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'outfits_list_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OutfitsListFilter {
  int get page => throw _privateConstructorUsedError;
  String get sort => throw _privateConstructorUsedError;
  String? get occasion => throw _privateConstructorUsedError;
  bool get onlyFavorites => throw _privateConstructorUsedError;
  bool get onlyWithLookPhoto => throw _privateConstructorUsedError;

  /// Create a copy of OutfitsListFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutfitsListFilterCopyWith<OutfitsListFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutfitsListFilterCopyWith<$Res> {
  factory $OutfitsListFilterCopyWith(
    OutfitsListFilter value,
    $Res Function(OutfitsListFilter) then,
  ) = _$OutfitsListFilterCopyWithImpl<$Res, OutfitsListFilter>;
  @useResult
  $Res call({
    int page,
    String sort,
    String? occasion,
    bool onlyFavorites,
    bool onlyWithLookPhoto,
  });
}

/// @nodoc
class _$OutfitsListFilterCopyWithImpl<$Res, $Val extends OutfitsListFilter>
    implements $OutfitsListFilterCopyWith<$Res> {
  _$OutfitsListFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutfitsListFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sort = null,
    Object? occasion = freezed,
    Object? onlyFavorites = null,
    Object? onlyWithLookPhoto = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            sort: null == sort
                ? _value.sort
                : sort // ignore: cast_nullable_to_non_nullable
                      as String,
            occasion: freezed == occasion
                ? _value.occasion
                : occasion // ignore: cast_nullable_to_non_nullable
                      as String?,
            onlyFavorites: null == onlyFavorites
                ? _value.onlyFavorites
                : onlyFavorites // ignore: cast_nullable_to_non_nullable
                      as bool,
            onlyWithLookPhoto: null == onlyWithLookPhoto
                ? _value.onlyWithLookPhoto
                : onlyWithLookPhoto // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OutfitsListFilterImplCopyWith<$Res>
    implements $OutfitsListFilterCopyWith<$Res> {
  factory _$$OutfitsListFilterImplCopyWith(
    _$OutfitsListFilterImpl value,
    $Res Function(_$OutfitsListFilterImpl) then,
  ) = __$$OutfitsListFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int page,
    String sort,
    String? occasion,
    bool onlyFavorites,
    bool onlyWithLookPhoto,
  });
}

/// @nodoc
class __$$OutfitsListFilterImplCopyWithImpl<$Res>
    extends _$OutfitsListFilterCopyWithImpl<$Res, _$OutfitsListFilterImpl>
    implements _$$OutfitsListFilterImplCopyWith<$Res> {
  __$$OutfitsListFilterImplCopyWithImpl(
    _$OutfitsListFilterImpl _value,
    $Res Function(_$OutfitsListFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OutfitsListFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sort = null,
    Object? occasion = freezed,
    Object? onlyFavorites = null,
    Object? onlyWithLookPhoto = null,
  }) {
    return _then(
      _$OutfitsListFilterImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        sort: null == sort
            ? _value.sort
            : sort // ignore: cast_nullable_to_non_nullable
                  as String,
        occasion: freezed == occasion
            ? _value.occasion
            : occasion // ignore: cast_nullable_to_non_nullable
                  as String?,
        onlyFavorites: null == onlyFavorites
            ? _value.onlyFavorites
            : onlyFavorites // ignore: cast_nullable_to_non_nullable
                  as bool,
        onlyWithLookPhoto: null == onlyWithLookPhoto
            ? _value.onlyWithLookPhoto
            : onlyWithLookPhoto // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OutfitsListFilterImpl implements _OutfitsListFilter {
  const _$OutfitsListFilterImpl({
    this.page = 1,
    this.sort = 'newest',
    this.occasion,
    this.onlyFavorites = false,
    this.onlyWithLookPhoto = false,
  });

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final String sort;
  @override
  final String? occasion;
  @override
  @JsonKey()
  final bool onlyFavorites;
  @override
  @JsonKey()
  final bool onlyWithLookPhoto;

  @override
  String toString() {
    return 'OutfitsListFilter(page: $page, sort: $sort, occasion: $occasion, onlyFavorites: $onlyFavorites, onlyWithLookPhoto: $onlyWithLookPhoto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfitsListFilterImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.occasion, occasion) ||
                other.occasion == occasion) &&
            (identical(other.onlyFavorites, onlyFavorites) ||
                other.onlyFavorites == onlyFavorites) &&
            (identical(other.onlyWithLookPhoto, onlyWithLookPhoto) ||
                other.onlyWithLookPhoto == onlyWithLookPhoto));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    page,
    sort,
    occasion,
    onlyFavorites,
    onlyWithLookPhoto,
  );

  /// Create a copy of OutfitsListFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfitsListFilterImplCopyWith<_$OutfitsListFilterImpl> get copyWith =>
      __$$OutfitsListFilterImplCopyWithImpl<_$OutfitsListFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _OutfitsListFilter implements OutfitsListFilter {
  const factory _OutfitsListFilter({
    final int page,
    final String sort,
    final String? occasion,
    final bool onlyFavorites,
    final bool onlyWithLookPhoto,
  }) = _$OutfitsListFilterImpl;

  @override
  int get page;
  @override
  String get sort;
  @override
  String? get occasion;
  @override
  bool get onlyFavorites;
  @override
  bool get onlyWithLookPhoto;

  /// Create a copy of OutfitsListFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfitsListFilterImplCopyWith<_$OutfitsListFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
