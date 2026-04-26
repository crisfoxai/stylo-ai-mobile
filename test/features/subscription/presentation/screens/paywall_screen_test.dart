import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/subscription/application/iap_service.dart';
import 'package:stylo_ai/features/subscription/domain/entities/subscription.dart';
import 'package:stylo_ai/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:stylo_ai/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:stylo_ai/features/subscription/presentation/screens/paywall_screen.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

// ── Fake subscription repository ────────────────────────────────────────────

class FakeSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<Subscription> getStatus() async => const Subscription(
        id: 'sub1',
        plan: SubscriptionPlan.free,
        status: SubscriptionStatus.active,
      );

  @override
  Future<Subscription> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  }) async =>
      const Subscription(
        id: 'sub1',
        plan: SubscriptionPlan.pro,
        status: SubscriptionStatus.active,
      );
}

// ── Fake IAP service ─────────────────────────────────────────────────────────

class FakeIapService implements IapService {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => Stream.empty();

  @override
  Future<bool> get isAvailable async => false;

  @override
  void listenToPurchases(void Function(List<PurchaseDetails>) handler) {}

  @override
  Future<List<ProductDetails>> loadProducts() async => [];

  @override
  Future<void> buyProduct(ProductDetails product) async {}

  @override
  Future<void> completePurchase(PurchaseDetails details) async {}

  @override
  String receiptDataFor(PurchaseDetails details) => '';

  @override
  String get platform => 'test';

  @override
  void dispose() {}
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget() {
  final router = GoRouter(
    initialLocation: '/paywall',
    routes: [
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const PaywallScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      subscriptionRepositoryProvider
          .overrideWithValue(FakeSubscriptionRepository()),
      iapServiceProvider.overrideWithValue(FakeIapService()),
      firebaseAuthProvider.overrideWithValue(_MockFirebaseAuth()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('PaywallScreen', () {
    testWidgets('renders STYLO logo and headline', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('STYLO'), findsOneWidget);
    });

    testWidgets('renders CTA button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Empezar trial gratis'), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('renders feature rows', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Guardarropa digital'), findsOneWidget);
    });

    testWidgets('renders price info', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Plan mensual'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();

      expect(find.text('Plan mensual'), findsOneWidget);
    });
  });
}
