import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/network/api_client.dart';
import '../../application/iap_service.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    SubscriptionRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) =>
      SubscriptionState(
        subscription: subscription ?? this.subscription,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;
  final Ref _ref;

  SubscriptionNotifier(this._repository, this._ref)
      : super(const SubscriptionState()) {
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await _repository.getStatus();
      state = state.copyWith(subscription: subscription, isLoading: false);
    } catch (e, st) {
      // ignore: avoid_print
      print('[SubscriptionNotifier] fetchStatus error: $e\n$st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await _repository.verifyPurchase(
        productId: productId,
        receiptData: receiptData,
        platform: platform,
      );
      state = state.copyWith(subscription: subscription, isLoading: false);
      _ref.invalidate(subscriptionNotifierProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final iapService = _ref.read(iapServiceProvider);
        final receiptData = iapService.receiptDataFor(purchase);
        verifyPurchase(
          productId: purchase.productID,
          receiptData: receiptData,
          platform: iapService.platform,
        );
        iapService.completePurchase(purchase);
      }
    }
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionRepositoryProvider), ref);
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).subscription?.isPremium ??
      false;
});

final hasTryonProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).subscription?.hasTryon ??
      false;
});

final hasChatProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionNotifierProvider).subscription?.hasChat ?? false;
});

final subscriptionPlanProvider = Provider<SubscriptionPlan>((ref) {
  return ref.watch(subscriptionNotifierProvider).subscription?.plan ??
      SubscriptionPlan.free;
});

// Convenience alias kept for backwards compat with existing screens
final subscriptionProvider = subscriptionNotifierProvider;

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService();
  ref.onDispose(service.dispose);
  return service;
});
