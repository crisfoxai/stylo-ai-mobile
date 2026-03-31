import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<Subscription> getStatus();
  Future<Subscription> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  });
}
