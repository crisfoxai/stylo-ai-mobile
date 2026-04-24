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

Widget buildTestWidget() {
  final router = GoRouter(
    initialLocation: '/try-on',
    routes: [
      GoRoute(
        path: '/try-on',
        builder: (_, __) => const VirtualTryOnScreen(),
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
      isPremiumProvider.overrideWithValue(false),
      tryOnProvider.overrideWith((ref) => TryOnNotifier(_FakeTryOnDataSource())),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Future<void> pumpScreen(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(buildTestWidget());
  await tester.pump();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('VirtualTryOnScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Prueba Virtual'), findsOneWidget);
    });

    testWidgets('renders photo placeholder text', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Seleccioná tu foto'), findsOneWidget);
    });

    testWidgets('renders camera and gallery buttons', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Cámara'), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);
    });

    testWidgets('renders process button', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Probarme el outfit'), findsOneWidget);
    });

    testWidgets('renders premium paywall banner when not premium', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Función Premium'), findsOneWidget);
    });
  });
}
