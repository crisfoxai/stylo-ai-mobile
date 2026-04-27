// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReferralStats _$ReferralStatsFromJson(Map<String, dynamic> json) {
  return _ReferralStats.fromJson(json);
}

/// @nodoc
mixin _$ReferralStats {
  String get referralCode => throw _privateConstructorUsedError;
  int get totalReferred => throw _privateConstructorUsedError;
  int get validated => throw _privateConstructorUsedError;
  bool get bonusDaysActive => throw _privateConstructorUsedError;
  String? get premiumAccessUntil => throw _privateConstructorUsedError;
  String get referralLink => throw _privateConstructorUsedError;
  bool get alreadyReferred => throw _privateConstructorUsedError;

  /// Serializes this ReferralStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferralStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferralStatsCopyWith<ReferralStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralStatsCopyWith<$Res> {
  factory $ReferralStatsCopyWith(
    ReferralStats value,
    $Res Function(ReferralStats) then,
  ) = _$ReferralStatsCopyWithImpl<$Res, ReferralStats>;
  @useResult
  $Res call({
    String referralCode,
    int totalReferred,
    int validated,
    bool bonusDaysActive,
    String? premiumAccessUntil,
    String referralLink,
    bool alreadyReferred,
  });
}

/// @nodoc
class _$ReferralStatsCopyWithImpl<$Res, $Val extends ReferralStats>
    implements $ReferralStatsCopyWith<$Res> {
  _$ReferralStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferralStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referralCode = null,
    Object? totalReferred = null,
    Object? validated = null,
    Object? bonusDaysActive = null,
    Object? premiumAccessUntil = freezed,
    Object? referralLink = null,
    Object? alreadyReferred = null,
  }) {
    return _then(
      _value.copyWith(
            referralCode: null == referralCode
                ? _value.referralCode
                : referralCode // ignore: cast_nullable_to_non_nullable
                      as String,
            totalReferred: null == totalReferred
                ? _value.totalReferred
                : totalReferred // ignore: cast_nullable_to_non_nullable
                      as int,
            validated: null == validated
                ? _value.validated
                : validated // ignore: cast_nullable_to_non_nullable
                      as int,
            bonusDaysActive: null == bonusDaysActive
                ? _value.bonusDaysActive
                : bonusDaysActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            premiumAccessUntil: freezed == premiumAccessUntil
                ? _value.premiumAccessUntil
                : premiumAccessUntil // ignore: cast_nullable_to_non_nullable
                      as String?,
            referralLink: null == referralLink
                ? _value.referralLink
                : referralLink // ignore: cast_nullable_to_non_nullable
                      as String,
            alreadyReferred: null == alreadyReferred
                ? _value.alreadyReferred
                : alreadyReferred // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferralStatsImplCopyWith<$Res>
    implements $ReferralStatsCopyWith<$Res> {
  factory _$$ReferralStatsImplCopyWith(
    _$ReferralStatsImpl value,
    $Res Function(_$ReferralStatsImpl) then,
  ) = __$$ReferralStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String referralCode,
    int totalReferred,
    int validated,
    bool bonusDaysActive,
    String? premiumAccessUntil,
    String referralLink,
    bool alreadyReferred,
  });
}

/// @nodoc
class __$$ReferralStatsImplCopyWithImpl<$Res>
    extends _$ReferralStatsCopyWithImpl<$Res, _$ReferralStatsImpl>
    implements _$$ReferralStatsImplCopyWith<$Res> {
  __$$ReferralStatsImplCopyWithImpl(
    _$ReferralStatsImpl _value,
    $Res Function(_$ReferralStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferralStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? referralCode = null,
    Object? totalReferred = null,
    Object? validated = null,
    Object? bonusDaysActive = null,
    Object? premiumAccessUntil = freezed,
    Object? referralLink = null,
    Object? alreadyReferred = null,
  }) {
    return _then(
      _$ReferralStatsImpl(
        referralCode: null == referralCode
            ? _value.referralCode
            : referralCode // ignore: cast_nullable_to_non_nullable
                  as String,
        totalReferred: null == totalReferred
            ? _value.totalReferred
            : totalReferred // ignore: cast_nullable_to_non_nullable
                  as int,
        validated: null == validated
            ? _value.validated
            : validated // ignore: cast_nullable_to_non_nullable
                  as int,
        bonusDaysActive: null == bonusDaysActive
            ? _value.bonusDaysActive
            : bonusDaysActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        premiumAccessUntil: freezed == premiumAccessUntil
            ? _value.premiumAccessUntil
            : premiumAccessUntil // ignore: cast_nullable_to_non_nullable
                  as String?,
        referralLink: null == referralLink
            ? _value.referralLink
            : referralLink // ignore: cast_nullable_to_non_nullable
                  as String,
        alreadyReferred: null == alreadyReferred
            ? _value.alreadyReferred
            : alreadyReferred // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferralStatsImpl implements _ReferralStats {
  const _$ReferralStatsImpl({
    required this.referralCode,
    this.totalReferred = 0,
    this.validated = 0,
    this.bonusDaysActive = false,
    this.premiumAccessUntil,
    required this.referralLink,
    this.alreadyReferred = false,
  });

  factory _$ReferralStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferralStatsImplFromJson(json);

  @override
  final String referralCode;
  @override
  @JsonKey()
  final int totalReferred;
  @override
  @JsonKey()
  final int validated;
  @override
  @JsonKey()
  final bool bonusDaysActive;
  @override
  final String? premiumAccessUntil;
  @override
  final String referralLink;
  @override
  @JsonKey()
  final bool alreadyReferred;

  @override
  String toString() {
    return 'ReferralStats(referralCode: $referralCode, totalReferred: $totalReferred, validated: $validated, bonusDaysActive: $bonusDaysActive, premiumAccessUntil: $premiumAccessUntil, referralLink: $referralLink, alreadyReferred: $alreadyReferred)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralStatsImpl &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.totalReferred, totalReferred) ||
                other.totalReferred == totalReferred) &&
            (identical(other.validated, validated) ||
                other.validated == validated) &&
            (identical(other.bonusDaysActive, bonusDaysActive) ||
                other.bonusDaysActive == bonusDaysActive) &&
            (identical(other.premiumAccessUntil, premiumAccessUntil) ||
                other.premiumAccessUntil == premiumAccessUntil) &&
            (identical(other.referralLink, referralLink) ||
                other.referralLink == referralLink) &&
            (identical(other.alreadyReferred, alreadyReferred) ||
                other.alreadyReferred == alreadyReferred));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    referralCode,
    totalReferred,
    validated,
    bonusDaysActive,
    premiumAccessUntil,
    referralLink,
    alreadyReferred,
  );

  /// Create a copy of ReferralStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralStatsImplCopyWith<_$ReferralStatsImpl> get copyWith =>
      __$$ReferralStatsImplCopyWithImpl<_$ReferralStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferralStatsImplToJson(this);
  }
}

abstract class _ReferralStats implements ReferralStats {
  const factory _ReferralStats({
    required final String referralCode,
    final int totalReferred,
    final int validated,
    final bool bonusDaysActive,
    final String? premiumAccessUntil,
    required final String referralLink,
    final bool alreadyReferred,
  }) = _$ReferralStatsImpl;

  factory _ReferralStats.fromJson(Map<String, dynamic> json) =
      _$ReferralStatsImpl.fromJson;

  @override
  String get referralCode;
  @override
  int get totalReferred;
  @override
  int get validated;
  @override
  bool get bonusDaysActive;
  @override
  String? get premiumAccessUntil;
  @override
  String get referralLink;
  @override
  bool get alreadyReferred;

  /// Create a copy of ReferralStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferralStatsImplCopyWith<_$ReferralStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
