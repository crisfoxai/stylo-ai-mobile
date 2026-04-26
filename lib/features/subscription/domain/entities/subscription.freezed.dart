// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  SubscriptionPlan get plan => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  String? get platform => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  int get tryonUsedThisMonth => throw _privateConstructorUsedError;
  int get chatMessagesUsedThisMonth => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    SubscriptionPlan plan,
    SubscriptionStatus status,
    String? platform,
    String? productId,
    DateTime? expiresAt,
    int tryonUsedThisMonth,
    int chatMessagesUsedThisMonth,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plan = null,
    Object? status = null,
    Object? platform = freezed,
    Object? productId = freezed,
    Object? expiresAt = freezed,
    Object? tryonUsedThisMonth = null,
    Object? chatMessagesUsedThisMonth = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlan,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            platform: freezed == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String?,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            tryonUsedThisMonth: null == tryonUsedThisMonth
                ? _value.tryonUsedThisMonth
                : tryonUsedThisMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            chatMessagesUsedThisMonth: null == chatMessagesUsedThisMonth
                ? _value.chatMessagesUsedThisMonth
                : chatMessagesUsedThisMonth // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    SubscriptionPlan plan,
    SubscriptionStatus status,
    String? platform,
    String? productId,
    DateTime? expiresAt,
    int tryonUsedThisMonth,
    int chatMessagesUsedThisMonth,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plan = null,
    Object? status = null,
    Object? platform = freezed,
    Object? productId = freezed,
    Object? expiresAt = freezed,
    Object? tryonUsedThisMonth = null,
    Object? chatMessagesUsedThisMonth = null,
  }) {
    return _then(
      _$SubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlan,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        platform: freezed == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String?,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        tryonUsedThisMonth: null == tryonUsedThisMonth
            ? _value.tryonUsedThisMonth
            : tryonUsedThisMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        chatMessagesUsedThisMonth: null == chatMessagesUsedThisMonth
            ? _value.chatMessagesUsedThisMonth
            : chatMessagesUsedThisMonth // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionImpl extends _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    this.plan = SubscriptionPlan.free,
    this.status = SubscriptionStatus.free,
    this.platform,
    this.productId,
    this.expiresAt,
    this.tryonUsedThisMonth = 0,
    this.chatMessagesUsedThisMonth = 0,
  }) : super._();

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final SubscriptionPlan plan;
  @override
  @JsonKey()
  final SubscriptionStatus status;
  @override
  final String? platform;
  @override
  final String? productId;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final int tryonUsedThisMonth;
  @override
  @JsonKey()
  final int chatMessagesUsedThisMonth;

  @override
  String toString() {
    return 'Subscription(id: $id, plan: $plan, status: $status, platform: $platform, productId: $productId, expiresAt: $expiresAt, tryonUsedThisMonth: $tryonUsedThisMonth, chatMessagesUsedThisMonth: $chatMessagesUsedThisMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.tryonUsedThisMonth, tryonUsedThisMonth) ||
                other.tryonUsedThisMonth == tryonUsedThisMonth) &&
            (identical(
                  other.chatMessagesUsedThisMonth,
                  chatMessagesUsedThisMonth,
                ) ||
                other.chatMessagesUsedThisMonth == chatMessagesUsedThisMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    plan,
    status,
    platform,
    productId,
    expiresAt,
    tryonUsedThisMonth,
    chatMessagesUsedThisMonth,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription extends Subscription {
  const factory _Subscription({
    required final String id,
    final SubscriptionPlan plan,
    final SubscriptionStatus status,
    final String? platform,
    final String? productId,
    final DateTime? expiresAt,
    final int tryonUsedThisMonth,
    final int chatMessagesUsedThisMonth,
  }) = _$SubscriptionImpl;
  const _Subscription._() : super._();

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  SubscriptionPlan get plan;
  @override
  SubscriptionStatus get status;
  @override
  String? get platform;
  @override
  String? get productId;
  @override
  DateTime? get expiresAt;
  @override
  int get tryonUsedThisMonth;
  @override
  int get chatMessagesUsedThisMonth;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
