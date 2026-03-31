import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
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

  SubscriptionNotifier(this._repository) : super(const SubscriptionState()) {
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await _repository.getStatus();
      state = state.copyWith(subscription: subscription, isLoading: false);
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionRepositoryProvider));
});

final isPremiumProvider = Provider<bool>((ref) {
  final sub = ref.watch(subscriptionNotifierProvider).subscription;
  return sub?.isPremium ?? false;
});
