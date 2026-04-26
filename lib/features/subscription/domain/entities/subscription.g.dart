// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      plan:
          $enumDecodeNullable(_$SubscriptionPlanEnumMap, json['plan']) ??
          SubscriptionPlan.free,
      status:
          $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
          SubscriptionStatus.free,
      platform: json['platform'] as String?,
      productId: json['productId'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      tryonUsedThisMonth: (json['tryonUsedThisMonth'] as num?)?.toInt() ?? 0,
      chatMessagesUsedThisMonth:
          (json['chatMessagesUsedThisMonth'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan': _$SubscriptionPlanEnumMap[instance.plan]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'platform': instance.platform,
      'productId': instance.productId,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'tryonUsedThisMonth': instance.tryonUsedThisMonth,
      'chatMessagesUsedThisMonth': instance.chatMessagesUsedThisMonth,
    };

const _$SubscriptionPlanEnumMap = {
  SubscriptionPlan.free: 'free',
  SubscriptionPlan.stylist: 'stylist',
  SubscriptionPlan.pro: 'pro',
  SubscriptionPlan.proUnlimited: 'proUnlimited',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.free: 'free',
  SubscriptionStatus.grace: 'grace',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
};
