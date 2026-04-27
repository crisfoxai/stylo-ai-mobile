import 'package:dio/dio.dart';
import '../../../../core/network/backend_compat.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/referral_stats.dart';

class ReferralRemoteDataSource {
  final Dio _dio;

  ReferralRemoteDataSource(this._dio);

  Future<ReferralStats> getMyStats() async {
    final response = await _dio.get(Endpoints.referralMyStats);
    final data = BackendCompat.extractMap(response.data);
    return ReferralStats.fromJson(data);
  }

  Future<String> applyCode(String code, String deviceFingerprint) async {
    final response = await _dio.post(
      Endpoints.referralApplyCode,
      data: {'code': code, 'deviceFingerprint': deviceFingerprint},
    );
    final data = BackendCompat.extractMap(response.data);
    return (data['referrerName'] as String?) ?? '';
  }
}
