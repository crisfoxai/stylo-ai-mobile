import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';

class TryonCredits {
  final int used;
  final int? limit;
  final DateTime? resetAt;

  const TryonCredits({required this.used, this.limit, this.resetAt});

  int get remaining => limit == null ? 999 : limit! - used;
  bool get isUnlimited => limit == null;
  bool get isLow => !isUnlimited && remaining < 5;
  bool get isEmpty => !isUnlimited && remaining <= 0;
}

// Derives from subscription state. Once Ariel adds tryonsUsedThisMonth
// to GET /users/me, replace `used: 0` with the real field.
final tryonCreditsProvider = Provider<TryonCredits>((ref) {
  final sub = ref.watch(subscriptionNotifierProvider).subscription;
  if (sub == null) return const TryonCredits(used: 0, limit: 20);

  final isUnlimited = sub.plan.jsonValue == 'pro_unlimited' && sub.isActive;
  if (isUnlimited) return const TryonCredits(used: 0, limit: null);

  final limit = sub.tryonLimit;
  final used = sub.tryonUsedThisMonth;
  return TryonCredits(used: used, limit: limit > 0 ? limit : 20);
});
