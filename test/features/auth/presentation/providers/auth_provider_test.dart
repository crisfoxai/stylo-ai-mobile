import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';
import 'package:stylo_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';

// ── Fake implementations ─────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  bool signOutCalled = false;
  String? forgotPasswordEmail;
  Exception? errorToThrow;

  void setCurrentUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void throwOnNextCall(Exception e) => errorToThrow = e;

  AuthResult _makeResult(User user) => AuthResult(
        user: user,
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresIn: 3600,
      );

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
      id: 'user-email',
      email: email,
      firstName: 'Email',
      lastName: 'User',
      createdAt: DateTime(2024),
    );
    _currentUser = user;
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signUpWithEmail(
      String email, String password, String firstName, String lastName) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
      id: 'user-new',
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime(2024),
    );
    _currentUser = user;
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
      id: 'google-user',
      email: 'google@stylo.ai',
      firstName: 'Google',
      lastName: 'User',
      createdAt: DateTime(2024),
    );
    return _makeResult(user);
  }

  @override
  Future<AuthResult> signInWithApple() async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final user = User(
      id: 'apple-user',
      email: 'apple@stylo.ai',
      firstName: 'Apple',
      lastName: 'User',
      createdAt: DateTime(2024),
    );
    return _makeResult(user);
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _currentUser = null;
  }

  @override
  Future<AuthResult?> refreshToken() async => null;

  @override
  Future<void> forgotPassword(String email) async {
    forgotPasswordEmail = email;
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void dispose() => _controller.close();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ProviderContainer makeContainer(FakeAuthRepository repo) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  late FakeAuthRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    container = makeContainer(fakeRepo);
  });

  tearDown(() {
    container.dispose();
    fakeRepo.dispose();
  });

  // ── AuthStatus enum ─────────────────────────────────────────────────────────

  group('AuthStatus enum', () {
    test('has exactly five values', () {
      expect(AuthStatus.values.length, 5);
    });

    test('contains expected values', () {
      expect(AuthStatus.values, containsAll([
        AuthStatus.initial,
        AuthStatus.loading,
        AuthStatus.authenticated,
        AuthStatus.unauthenticated,
        AuthStatus.error,
      ]));
    });
  });

  // ── AuthState ───────────────────────────────────────────────────────────────

  group('AuthState', () {
    test('default constructor has initial status, null user, null error', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith overrides provided fields', () {
      const state = AuthState();
      final updated = state.copyWith(status: AuthStatus.loading);
      expect(updated.status, AuthStatus.loading);
      expect(updated.user, isNull);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith preserves unmodified fields', () {
      final user = User(
        id: 'u1',
        email: 'a@b.com',
        firstName: 'A',
        lastName: 'B',
        createdAt: DateTime(2024),
      );
      final state = AuthState(status: AuthStatus.authenticated, user: user);
      final updated = state.copyWith(errorMessage: 'oops');
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user, user);
      expect(updated.errorMessage, 'oops');
    });

    test('copyWith can clear errorMessage by passing null', () {
      const state = AuthState(status: AuthStatus.error, errorMessage: 'fail');
      final updated = state.copyWith(errorMessage: null);
      expect(updated.errorMessage, isNull);
    });
  });

  // ── AuthNotifier initialization ─────────────────────────────────────────────

  group('AuthNotifier initialization', () {
    test('sets unauthenticated state when no current user', () {
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
    });

    test('sets authenticated state when repository has a current user', () {
      final user = User(
        id: 'existing-user',
        email: 'existing@stylo.ai',
        firstName: 'Existing',
        lastName: 'User',
        createdAt: DateTime(2024),
      );
      final repoWithUser = FakeAuthRepository();
      repoWithUser.setCurrentUser(user);
      final c = makeContainer(repoWithUser);
      addTearDown(() {
        c.dispose();
        repoWithUser.dispose();
      });

      final state = c.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, user);
    });
  });

  // ── signInWithEmail ─────────────────────────────────────────────────────────

  group('AuthNotifier.signInWithEmail', () {
    test('transitions to authenticated on success', () async {
      await container
          .read(authNotifierProvider.notifier)
          .signInWithEmail('user@stylo.ai', 'secret123');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, isNotNull);
      expect(state.user!.email, 'user@stylo.ai');
    });

    test('transitions to error state on failure', () async {
      fakeRepo.throwOnNextCall(Exception('Invalid credentials'));

      await container
          .read(authNotifierProvider.notifier)
          .signInWithEmail('bad@email.com', 'wrong');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('Invalid credentials'));
    });
  });

  // ── signUpWithEmail ─────────────────────────────────────────────────────────

  group('AuthNotifier.signUpWithEmail', () {
    test('transitions to authenticated on success', () async {
      await container
          .read(authNotifierProvider.notifier)
          .signUpWithEmail('new@stylo.ai', 'pass123', 'Carlos', 'López');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user!.firstName, 'Carlos');
      expect(state.user!.lastName, 'López');
    });

    test('transitions to error state on failure', () async {
      fakeRepo.throwOnNextCall(Exception('Email already in use'));

      await container
          .read(authNotifierProvider.notifier)
          .signUpWithEmail('dup@stylo.ai', 'pass', 'Dup', 'User');

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('Email already in use'));
    });
  });

  // ── signInWithGoogle ────────────────────────────────────────────────────────

  group('AuthNotifier.signInWithGoogle', () {
    test('transitions to authenticated on success', () async {
      await container.read(authNotifierProvider.notifier).signInWithGoogle();
      expect(
          container.read(authNotifierProvider).status, AuthStatus.authenticated);
    });

    test('transitions to error on failure', () async {
      fakeRepo.throwOnNextCall(Exception('Google sign in cancelled'));
      await container.read(authNotifierProvider.notifier).signInWithGoogle();
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('Google sign in cancelled'));
    });
  });

  // ── signInWithApple ─────────────────────────────────────────────────────────

  group('AuthNotifier.signInWithApple', () {
    test('transitions to authenticated on success', () async {
      await container.read(authNotifierProvider.notifier).signInWithApple();
      expect(
          container.read(authNotifierProvider).status, AuthStatus.authenticated);
    });

    test('transitions to error on failure', () async {
      fakeRepo.throwOnNextCall(Exception('Apple sign in failed'));
      await container.read(authNotifierProvider.notifier).signInWithApple();
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('Apple sign in failed'));
    });
  });

  // ── signOut ─────────────────────────────────────────────────────────────────

  group('AuthNotifier.signOut', () {
    test('calls repository signOut and sets unauthenticated state', () async {
      await container
          .read(authNotifierProvider.notifier)
          .signInWithEmail('user@stylo.ai', 'pass');
      expect(container.read(authNotifierProvider).status,
          AuthStatus.authenticated);

      await container.read(authNotifierProvider.notifier).signOut();

      expect(fakeRepo.signOutCalled, isTrue);
      expect(container.read(authNotifierProvider).status,
          AuthStatus.unauthenticated);
      expect(container.read(authNotifierProvider).user, isNull);
    });
  });

  // ── forgotPassword ──────────────────────────────────────────────────────────

  group('AuthNotifier.forgotPassword', () {
    test('delegates to the repository with the provided email', () async {
      await container
          .read(authNotifierProvider.notifier)
          .forgotPassword('reset@stylo.ai');
      expect(fakeRepo.forgotPasswordEmail, 'reset@stylo.ai');
    });
  });

  // ── currentUserProvider ─────────────────────────────────────────────────────

  group('currentUserProvider', () {
    test('returns null when unauthenticated', () {
      expect(container.read(currentUserProvider), isNull);
    });

    test('returns user after successful sign in', () async {
      await container
          .read(authNotifierProvider.notifier)
          .signInWithEmail('u@stylo.ai', 'pass');
      expect(container.read(currentUserProvider), isNotNull);
    });

    test('returns null after sign out', () async {
      await container
          .read(authNotifierProvider.notifier)
          .signInWithEmail('u@stylo.ai', 'pass');
      await container.read(authNotifierProvider.notifier).signOut();
      expect(container.read(currentUserProvider), isNull);
    });
  });
}
