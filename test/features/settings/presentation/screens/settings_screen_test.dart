import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';
import 'package:stylo_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:stylo_ai/features/settings/presentation/screens/settings_screen.dart';

// ── Mock data ────────────────────────────────────────────────────────────────

final _mockUser = User(
  id: 'u1',
  email: 'maria@stylo.ai',
  firstName: 'María',
  lastName: 'López',
  createdAt: DateTime(2024),
);

// ── Fake repository ─────────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepository {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  @override
  User? get currentUser => _mockUser;

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
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget() {
  final router = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const Scaffold(body: Text('Auth')),
      ),
      GoRoute(
        path: '/style-quiz',
        builder: (_, __) => const Scaffold(body: Text('Style Quiz')),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const Scaffold(body: Text('Paywall')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(_mockUser),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('SettingsScreen', () {
    testWidgets('renders profile header with user data', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('María López'), findsOneWidget);
      expect(find.text('maria@stylo.ai'), findsOneWidget);
      expect(find.text('ML'), findsOneWidget);
    });

    testWidgets('renders all section headers', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('CUENTA'), findsOneWidget);
      expect(find.text('MI ESTILO'), findsOneWidget);

      // Scroll down to reveal remaining sections
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();

      expect(find.text('SUSCRIPCIÓN'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();

      expect(find.text('LEGAL'), findsOneWidget);
    });

    testWidgets('renders settings tiles', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Editar perfil'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Notificaciones'), findsOneWidget);
    });

    testWidgets('renders sign out button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Scroll to the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pump();

      expect(find.text('Cerrar sesión'), findsWidgets);
    });

    testWidgets('renders app bar with Perfil title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Perfil'), findsOneWidget);
    });
  });
}
