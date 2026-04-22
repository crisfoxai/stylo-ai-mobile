import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/network/endpoints.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  final fb.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource(this._dio, {fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  Future<AuthResult> login(String email, String password) async {
    // Authenticate with Firebase
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get Firebase JWT
    final idToken = await credential.user!.getIdToken();

    // Send JWT to backend for validation
    final response = await _dio.post(
      Endpoints.login,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {'email': email},
    );
    return _parseAuthResponse(response.data['data']);
  }

  Future<AuthResult> register(String email, String password, String firstName, String lastName) async {
    // Create user in Firebase
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name in Firebase
    await credential.user!.updateDisplayName('$firstName $lastName');

    // Get Firebase JWT
    final idToken = await credential.user!.getIdToken();

    // Send JWT + profile to backend
    final response = await _dio.post(
      Endpoints.register,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    return _parseAuthResponse(response.data['data']);
  }

  Future<AuthResult> googleSignIn(String idToken) async {
    final response = await _dio.post(Endpoints.googleAuth, data: {
      'idToken': idToken,
    });
    return _parseAuthResponse(response.data['data'], isNewUser: response.data['data']['user']['isNewUser'] as bool? ?? false);
  }

  Future<AuthResult> appleSignIn(String identityToken, String authorizationCode, String? firstName, String? lastName) async {
    final response = await _dio.post(Endpoints.appleAuth, data: {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    });
    return _parseAuthResponse(response.data['data'], isNewUser: response.data['data']['user']['isNewUser'] as bool? ?? false);
  }

  Future<Map<String, String>> refreshToken(String token) async {
    final response = await _dio.post(Endpoints.refreshToken, data: {
      'refreshToken': token,
    });
    final data = response.data['data'];
    return {
      'accessToken': data['accessToken'] as String,
      'refreshToken': data['refreshToken'] as String,
    };
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post(Endpoints.logout, data: {
      'refreshToken': refreshToken,
    });
    await _firebaseAuth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Get current Firebase user's ID token (JWT) for backend auth
  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  AuthResult _parseAuthResponse(Map<String, dynamic> data, {bool isNewUser = false}) {
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens = data['tokens'] as Map<String, dynamic>;
    return AuthResult(
      user: user,
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      expiresIn: tokens['expiresIn'] as int,
      isNewUser: isNewUser,
    );
  }
}
