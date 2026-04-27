import 'package:freezed_annotation/freezed_annotation.dart';

part 'referral_stats.freezed.dart';
part 'referral_stats.g.dart';

@freezed
class ReferralStats with _$ReferralStats {
  const factory ReferralStats({
    required String referralCode,
    @Default(0) int totalReferred,
    @Default(0) int validated,
    @Default(false) bool bonusDaysActive,
    String? premiumAccessUntil,
    required String referralLink,
    @Default(false) bool alreadyReferred,
  }) = _ReferralStats;

  factory ReferralStats.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatsFromJson(json);
}
