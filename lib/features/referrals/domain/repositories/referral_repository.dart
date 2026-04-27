import '../entities/referral_stats.dart';

abstract class ReferralRepository {
  Future<ReferralStats> getMyStats();
  Future<String> applyCode(String code, String deviceFingerprint);
}
