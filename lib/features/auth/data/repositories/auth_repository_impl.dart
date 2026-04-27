import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final GoogleSignIn _googleSignIn;
  final _authStateController = StreamController<User?>.broadcast();

  User? _currentUser;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource, this._googleSignIn) {
    _currentUser = _localDataSource.getUser();
    if (_currentUser != null) {
      _authStateController.add(_currentUser);
    }
    // When the auth interceptor calls FirebaseAuth.signOut() on persistent 401,
    // mirror that sign-out in our local state so GoRouter redirects to /auth.
    fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) {
      if (fbUser == null && _currentUser != null) {
        _localDataSource.clearAll().ignore();
        _currentUser = null;
        _authStateController.add(null);
      }
    });
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    final result = await _remoteDataSource.login(email, password);
    await _persistAuth(result);
    return result;
  }

  @override
  Future<AuthResult> signUpWithEmail(String email, String password, String firstName, String lastName) async {
    final result = await _remoteDataSource.register(email, password, firstName, lastName);
    await _persistAuth(result);
    return result;
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');
      final auth = await googleUser.authentication;
      if (auth.idToken == null) throw Exception('Google idToken unavailable');
      final result = await _remoteDataSource.googleSignIn(
        auth.idToken!,
        accessToken: auth.accessToken,
      );
      await _persistAuth(result);
      return result;
    } on Exception catch (e) {
      final message = e.toString();
      if (message.contains('PlatformException') ||
          message.contains('network_error') ||
          message.contains('sign_in_required') ||
          message.contains('ApiException') ||
          message.contains('UNSPECIFIED')) {
        throw Exception(
          'Google Sign-In no está disponible. Verifica tu conexión o usa otro método de inicio de sesión.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    // Sign In with Apple handled via sign_in_with_apple package
    throw UnimplementedError('Apple Sign In to be implemented with platform-specific code');
  }

  @override
  Future<void> signOut() async {
    final refreshToken = await _localDataSource.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _remoteDataSource.logout(refreshToken);
      } catch (_) {}
    }
    await _googleSignIn.signOut();
    await _localDataSource.clearAll();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<AuthResult?> refreshToken() async {
    // Firebase ID tokens are refreshed by the AuthInterceptor via getIdToken(true).
    // No backend token exchange is needed.
    return null;
  }

  @override
  Future<void> forgotPassword(String email) => _remoteDataSource.forgotPassword(email);

  Future<void> _persistAuth(AuthResult result) async {
    await _localDataSource.saveTokens(result.accessToken, result.refreshToken);
    await _localDataSource.saveUser(result.user);
    _currentUser = result.user;
    _authStateController.add(result.user);
  }
}
