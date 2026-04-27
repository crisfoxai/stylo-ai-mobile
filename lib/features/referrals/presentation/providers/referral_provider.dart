import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/device_fingerprint_service.dart';
import '../../data/datasources/referral_remote_datasource.dart';
import '../../data/repositories/referral_repository_impl.dart';
import '../../domain/entities/referral_stats.dart';
import '../../domain/repositories/referral_repository.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepositoryImpl(
    ReferralRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  return ref.read(referralRepositoryProvider).getMyStats();
});

// Holds a code received via deep link or manual entry before registration
final pendingReferralCodeProvider = StateProvider<String?>((ref) => null);

Future<void> applyReferralCode(
  WidgetRef ref,
  String code,
) async {
  final fingerprint = await DeviceFingerprintService().getFingerprint();
  await ref.read(referralRepositoryProvider).applyCode(code, fingerprint);
  ref.invalidate(referralStatsProvider);
}
