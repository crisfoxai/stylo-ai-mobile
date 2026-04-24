import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';
import 'package:stylo_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:stylo_ai/features/auth/presentation/screens/auth_screen.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

// ── Fake repository ───────────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepository {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  User? _currentUser;
  bool signInWithEmailCalled = false;
  bool signUpWithEmailCalled = false;
  bool signInWithGoogleCalled = false;
  bool signInWithAppleCalled = false;
  Exception? errorToThrow;

  void throwOnNextCall(Exception e) => errorToThrow = e;

  AuthResult _makeResult(User user) => AuthResult(
        user: user,
        accessToken: 'tok',
        refreshToken: 'rtok',
        expiresIn: 3600,
      );

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    signInWithEmailCalled = true;
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
        id: 'u1',
        email: email,
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime(2024));
    _currentUser = user;
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signUpWithEmail(String email, String password,
      String firstName, String lastName) async {
    signUpWithEmailCalled = true;
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
        id: 'u2',
        email: email,
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime(2024));
    _currentUser = user;
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    signInWithGoogleCalled = true;
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
        id: 'g1',
        email: 'g@g.com',
        firstName: 'G',
        lastName: 'User',
        createdAt: DateTime(2024));
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signInWithApple() async {
    signInWithAppleCalled = true;
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
        id: 'a1',
        email: 'a@apple.com',
        firstName: 'A',
        lastName: 'User',
        createdAt: DateTime(2024));
    return _makeResult(user);
  }

  @override
  Future<void> signOut() async => _currentUser = null;

  @override
  Future<AuthResult?> refreshToken() async => null;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void dispose() => _controller.close();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget buildTestWidget(FakeAuthRepository repo) {
  final router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('Home Screen')),
      ),
      GoRoute(
        path: '/style-quiz',
        builder: (_, __) => const Scaffold(body: Text('Style Quiz')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      firebaseAuthProvider.overrideWithValue(_MockFirebaseAuth()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
  });

  tearDown(() {
    fakeRepo.dispose();
  });

  group('AuthScreen', () {
    testWidgets('renders the STYLO logo text', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('STYLO'), findsOneWidget);
    });

    testWidgets('renders tagline text', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('Tu estilo, potenciado por IA'), findsOneWidget);
    });

    testWidgets('renders Google sign-in button', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('Continuar con Google'), findsOneWidget);
    });

    testWidgets('renders Apple sign-in button', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('Continuar con Apple'), findsOneWidget);
    });

    testWidgets('renders email text field in login mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('renders password text field in login mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, 'Contraseña'), findsOneWidget);
    });

    testWidgets('renders login submit button', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('shows toggle to register mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.text('¿No tenés cuenta? Registrate'), findsOneWidget);
    });

    testWidgets('does not show name fields in login mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, 'Nombre'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Apellido'), findsNothing);
    });

    testWidgets('switches to register mode when toggle is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.tap(find.text('¿No tenés cuenta? Registrate'));
      await tester.pumpAndSettle();

      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nombre'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Apellido'), findsOneWidget);
      expect(find.text('¿Ya tenés cuenta? Iniciá sesión'), findsOneWidget);
    });

    testWidgets('switches back to login mode from register mode',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.tap(find.text('¿No tenés cuenta? Registrate'));
      await tester.pumpAndSettle();
      expect(find.text('Crear cuenta'), findsOneWidget);

      // The toggle button may be off-screen — scroll to it first
      await tester.ensureVisible(find.text('¿Ya tenés cuenta? Iniciá sesión'));
      await tester.tap(find.text('¿Ya tenés cuenta? Iniciá sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nombre'), findsNothing);
    });

    testWidgets('tapping Google button triggers signInWithGoogle', (tester) async {
      // Throw to prevent navigation after successful sign-in
      fakeRepo.throwOnNextCall(Exception('google-cancelled'));
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.tap(find.text('Continuar con Google'));
      await tester.pump();

      expect(fakeRepo.signInWithGoogleCalled, isTrue);
    });

    testWidgets('tapping Apple button triggers signInWithApple', (tester) async {
      fakeRepo.throwOnNextCall(Exception('apple-cancelled'));
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.tap(find.text('Continuar con Apple'));
      await tester.pump();

      expect(fakeRepo.signInWithAppleCalled, isTrue);
    });

    testWidgets('does not submit login form when email is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(fakeRepo.signInWithEmailCalled, isFalse);
    });

    testWidgets('submits login form with valid email and password', (tester) async {
      // Throw to prevent navigation
      fakeRepo.throwOnNextCall(Exception('stop-nav'));
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'user@stylo.ai');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Contraseña'), 'password123');
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(fakeRepo.signInWithEmailCalled, isTrue);
    });

    testWidgets('register form requires name fields to be filled', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();

      // Switch to register mode
      await tester.tap(find.text('¿No tenés cuenta? Registrate'));
      await tester.pumpAndSettle();

      // Tap submit without filling name fields
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();

      expect(fakeRepo.signUpWithEmailCalled, isFalse);
    });

    testWidgets('shows legal disclaimer text', (tester) async {
      await tester.pumpWidget(buildTestWidget(fakeRepo));
      await tester.pump();
      // Ensure the legal text is scrolled into view using ensureVisible
      await tester.ensureVisible(
        find.text('Al continuar, aceptás los Términos y Política de Privacidad'),
      );
      expect(
          find.text(
              'Al continuar, aceptás los Términos y Política de Privacidad'),
          findsOneWidget);
    });
  });
}
