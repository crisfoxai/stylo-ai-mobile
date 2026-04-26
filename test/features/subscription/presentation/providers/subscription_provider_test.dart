import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/subscription/domain/entities/subscription.dart';
import 'package:stylo_ai/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:stylo_ai/features/subscription/presentation/providers/subscription_provider.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  Exception? errorToThrow;
  Subscription _sub = const Subscription(
    id: 'sub-1',
    plan: SubscriptionPlan.free,
    status: SubscriptionStatus.active,
  );

  void setSubscription(Subscription sub) => _sub = sub;

  @override
  Future<Subscription> getStatus() async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return _sub;
  }

  @override
  Future<Subscription> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  }) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return const Subscription(
      id: 'sub-1',
      plan: SubscriptionPlan.pro,
      status: SubscriptionStatus.active,
    );
  }
}

void main() {
  group('SubscriptionState', () {
    test('default has null subscription and no loading', () {
      const state = SubscriptionState();
      expect(state.subscription, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith overrides specified fields', () {
      const state = SubscriptionState();
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
    });
  });

  group('SubscriptionNotifier', () {
    late FakeSubscriptionRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeSubscriptionRepository();
      container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('fetches status on initialization', () async {
      container.read(subscriptionNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(subscriptionNotifierProvider);
      expect(state.subscription, isNotNull);
      expect(state.subscription!.plan, SubscriptionPlan.free);
      expect(state.isLoading, isFalse);
    });

    test('sets error on fetch failure', () async {
      final errorRepo = FakeSubscriptionRepository();
      errorRepo.errorToThrow = Exception('Network error');
      final c = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWithValue(errorRepo),
        ],
      );
      addTearDown(c.dispose);

      c.read(subscriptionNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = c.read(subscriptionNotifierProvider);
      expect(state.error, contains('Network error'));
      expect(state.isLoading, isFalse);
    });

    test('verifyPurchase updates to premium on success', () async {
      container.read(subscriptionNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await container.read(subscriptionNotifierProvider.notifier).verifyPurchase(
            productId: 'premium_monthly',
            receiptData: 'receipt',
            platform: 'ios',
          );

      final state = container.read(subscriptionNotifierProvider);
      expect(state.subscription!.plan, SubscriptionPlan.pro);
      expect(state.isLoading, isFalse);
    });

    test('verifyPurchase sets error on failure', () async {
      container.read(subscriptionNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      fakeRepo.errorToThrow = Exception('Invalid receipt');
      await container.read(subscriptionNotifierProvider.notifier).verifyPurchase(
            productId: 'premium_monthly',
            receiptData: 'bad',
            platform: 'ios',
          );

      final state = container.read(subscriptionNotifierProvider);
      expect(state.error, contains('Invalid receipt'));
    });
  });

  group('isPremiumProvider', () {
    test('returns false when no subscription', () {
      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider
              .overrideWithValue(FakeSubscriptionRepository()),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(isPremiumProvider), isFalse);
    });
  });
}
