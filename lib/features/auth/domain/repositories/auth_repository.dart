import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUpWithEmail(String email, String password, String firstName, String lastName);
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<void> signOut();
  Future<AuthResult?> refreshToken();
  Future<void> forgotPassword(String email);
  Stream<User?> get authStateChanges;
  User? get currentUser;
}

class AuthResult {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final bool isNewUser;

  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.isNewUser = false,
  });
}
