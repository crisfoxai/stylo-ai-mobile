import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:stylo_ai/features/try_on/data/datasources/try_on_remote_datasource.dart';
import 'package:stylo_ai/features/try_on/presentation/providers/try_on_provider.dart';
import 'package:stylo_ai/features/try_on/presentation/screens/virtual_try_on_screen.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _FakeTryOnDataSource extends TryOnRemoteDataSource {
  _FakeTryOnDataSource() : super(Dio());
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget({bool hasTryon = false}) {
  final router = GoRouter(
    initialLocation: '/try-on',
    routes: [
      GoRoute(
        path: '/try-on',
        builder: (_, __) => const VirtualTryOnScreen(garmentId: 'garment-1'),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const Scaffold(body: Text('Paywall')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      firebaseAuthProvider.overrideWithValue(_MockFirebaseAuth()),
      hasTryonProvider.overrideWithValue(hasTryon),
      tryOnProvider.overrideWith((ref) => TryOnNotifier(_FakeTryOnDataSource())),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Future<void> pumpScreen(WidgetTester tester, {bool hasTryon = true}) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(buildTestWidget(hasTryon: hasTryon));
  await tester.pump();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('VirtualTryOnScreen', () {
    testWidgets('renders app bar with title when hasTryon', (tester) async {
      await pumpScreen(tester, hasTryon: true);
      expect(find.text('Prueba Virtual'), findsOneWidget);
    });

    testWidgets('renders photo placeholder text when hasTryon', (tester) async {
      await pumpScreen(tester, hasTryon: true);
      expect(find.text('Seleccioná tu foto'), findsOneWidget);
    });

    testWidgets('renders camera and gallery buttons when hasTryon', (tester) async {
      await pumpScreen(tester, hasTryon: true);
      expect(find.text('Cámara'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);
    });

    testWidgets('renders process button when hasTryon', (tester) async {
      await pumpScreen(tester, hasTryon: true);
      expect(find.text('Probarme la prenda'), findsOneWidget);
    });

    testWidgets('shows paywall screen when user does not have tryon access', (tester) async {
      await pumpScreen(tester, hasTryon: false);
      await tester.pump(const Duration(milliseconds: 100));
      // PaywallScreen is shown instead of VirtualTryOnScreen content
      expect(find.text('Prueba Virtual'), findsNothing);
    });
  });
}
