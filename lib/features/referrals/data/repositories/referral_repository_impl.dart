import '../../domain/entities/referral_stats.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_remote_datasource.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ReferralRemoteDataSource _remoteDataSource;

  ReferralRepositoryImpl(this._remoteDataSource);

  @override
  Future<ReferralStats> getMyStats() => _remoteDataSource.getMyStats();

  @override
  Future<String> applyCode(String code, String deviceFingerprint) =>
      _remoteDataSource.applyCode(code, deviceFingerprint);
}
