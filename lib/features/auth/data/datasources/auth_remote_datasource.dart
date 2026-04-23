import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../../../../core/network/endpoints.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  final fb.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource(this._dio, {fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  Future<AuthResult> login(String email, String password) async {
    debugPrint('[AUTH] Firebase sign-in start');
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('[AUTH] Firebase sign-in ok, uid=${credential.user!.uid}');

    final idToken = await credential.user!.getIdToken();
    debugPrint('[AUTH] idToken length=${idToken?.length ?? 0}');

    debugPrint('[AUTH] POST ${_dio.options.baseUrl}${Endpoints.login} starting');
    final response = await _dio.post(
      Endpoints.login,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {'email': email},
    );
    debugPrint('[AUTH] POST /auth/login status=${response.statusCode}');
    return _parseAuthResponse(response.data['data']);
  }

  Future<AuthResult> register(String email, String password, String firstName, String lastName) async {
    debugPrint('[AUTH] Firebase register start');
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    debugPrint('[AUTH] Firebase register ok, uid=${credential.user!.uid}');

    await credential.user!.updateDisplayName('$firstName $lastName');

    final idToken = await credential.user!.getIdToken();
    debugPrint('[AUTH] idToken length=${idToken?.length ?? 0}');

    debugPrint('[AUTH] POST ${_dio.options.baseUrl}${Endpoints.register} starting');
    final response = await _dio.post(
      Endpoints.register,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    debugPrint('[AUTH] POST /auth/register status=${response.statusCode}');
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
