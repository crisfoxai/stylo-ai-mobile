import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Subscription> getStatus() => _remoteDataSource.getStatus();

  @override
  Future<Subscription> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  }) =>
      _remoteDataSource.verifyPurchase(
        productId: productId,
        receiptData: receiptData,
        platform: platform,
      );
}
