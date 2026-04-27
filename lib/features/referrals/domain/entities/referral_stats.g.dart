// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferralStatsImpl _$$ReferralStatsImplFromJson(Map<String, dynamic> json) =>
    _$ReferralStatsImpl(
      referralCode: json['referralCode'] as String,
      totalReferred: (json['totalReferred'] as num?)?.toInt() ?? 0,
      validated: (json['validated'] as num?)?.toInt() ?? 0,
      bonusDaysActive: json['bonusDaysActive'] as bool? ?? false,
      premiumAccessUntil: json['premiumAccessUntil'] as String?,
      referralLink: json['referralLink'] as String,
      alreadyReferred: json['alreadyReferred'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReferralStatsImplToJson(_$ReferralStatsImpl instance) =>
    <String, dynamic>{
      'referralCode': instance.referralCode,
      'totalReferred': instance.totalReferred,
      'validated': instance.validated,
      'bonusDaysActive': instance.bonusDaysActive,
      'premiumAccessUntil': instance.premiumAccessUntil,
      'referralLink': instance.referralLink,
      'alreadyReferred': instance.alreadyReferred,
    };
