import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';
import 'package:stylo_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:stylo_ai/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:stylo_ai/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:stylo_ai/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';

// ── Fake data sources ─────────────────────────────────────────────────────────

class FakeOnboardingDataSource implements OnboardingLocalDataSource {
  final bool _onboardingComplete;
  final bool _styleQuizComplete;

  const FakeOnboardingDataSource({
    bool onboardingComplete = false,
    bool styleQuizComplete = false,
  })  : _onboardingComplete = onboardingComplete,
        _styleQuizComplete = styleQuizComplete;

  @override
  bool get isOnboardingComplete => _onboardingComplete;

  @override
  Future<void> setOnboardingComplete() async {}

  @override
  bool get hasCompletedStyleQuiz => _styleQuizComplete;

  @override
  Future<void> setStyleQuizComplete() async {}
}

class FakeAuthRepository implements AuthRepository {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  final User? _currentUser;

  FakeAuthRepository({User? currentUser}) : _currentUser = currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  Future<AuthResult> signInWithEmail(String e, String p) async =>
      throw UnimplementedError();

  @override
  Future<AuthResult> signUpWithEmail(
          String e, String p, String f, String l) async =>
      throw UnimplementedError();

  @override
  Future<AuthResult> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<AuthResult> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResult?> refreshToken() async => null;

  @override
  Future<void> forgotPassword(String email) async {}

  void dispose() => _controller.close();
}

// ── Builder ───────────────────────────────────────────────────────────────────

Widget buildSplash({
  bool onboardingComplete = false,
  bool styleQuizComplete = false,
  User? currentUser,
}) {
  final fakeDs = FakeOnboardingDataSource(
    onboardingComplete: onboardingComplete,
    styleQuizComplete: styleQuizComplete,
  );
  final fakeAuthRepo = FakeAuthRepository(currentUser: currentUser);

  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
          path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/auth',
          builder: (_, __) => const Scaffold(body: Text('Auth Screen'))),
      GoRoute(
          path: '/onboarding',
          builder: (_, __) =>
              const Scaffold(body: Text('Onboarding Screen'))),
      GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home Screen'))),
      GoRoute(
          path: '/style-quiz',
          builder: (_, __) =>
              const Scaffold(body: Text('Style Quiz Screen'))),
    ],
  );

  return ProviderScope(
    overrides: [
      onboardingDataSourceProvider.overrideWithValue(fakeDs),
      authRepositoryProvider.overrideWithValue(fakeAuthRepo),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

/// Pump the widget, advance past the animation (1.5s) and navigation delay (2s).
Future<void> pumpSplashFully(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders the STYLO brand name during animation', (tester) async {
      await tester.pumpWidget(buildSplash());
      // Just pump one frame — before navigation delay fires
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('STYLO'), findsOneWidget);
      // Drain timers
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('renders the S logo letter during animation', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('S'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('renders a Scaffold', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Scaffold), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('renders FadeTransition for the logo animation', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FadeTransition), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('renders ScaleTransition for the logo animation', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ScaleTransition), findsAtLeastNWidgets(1));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('animation completes without errors', (tester) async {
      await pumpSplashFully(tester, buildSplash());
      // If we reach here without an assertion, the animation completed cleanly.
    });

    testWidgets('widget tree contains Center widgets', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Center), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('contains an AnimatedBuilder', (tester) async {
      await tester.pumpWidget(buildSplash());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to /onboarding when onboarding not complete',
        (tester) async {
      await pumpSplashFully(
          tester,
          buildSplash(
              onboardingComplete: false, styleQuizComplete: false));
      expect(find.text('Onboarding Screen'), findsOneWidget);
    });

    testWidgets('navigates to /auth when onboarding complete, user not signed in',
        (tester) async {
      await pumpSplashFully(
          tester,
          buildSplash(
              onboardingComplete: true, styleQuizComplete: false));
      expect(find.text('Auth Screen'), findsOneWidget);
    });
  });
}
