import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/user.dart';
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

    final url = '${_dio.options.baseUrl}${Endpoints.login}';
    debugPrint('[AUTH] POST $url starting');
    try {
      final response = await _dio
          .post(
            Endpoints.login,
            options: Options(headers: {'Authorization': 'Bearer $idToken'}),
            // TODO(TL): backend Docker uses {email,password}; source uses Firebase-only
            // /auth/session. Remove `password` once Ariel aligns Docker↔source (card_Ea2AwaQhoDTE).
            data: {'email': email, 'password': password},
          )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint('[AUTH] MANUAL TIMEOUT 20s on $url');
        throw TimeoutException('Backend /auth/login no respondió en 20s');
      });
      debugPrint('[AUTH] POST /auth/login status=${response.statusCode}');
      return _parseAuthResponse(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
        '[AUTH] DioException type=${e.type} '
        'status=${e.response?.statusCode} msg=${e.message} error=${e.error}',
      );
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[AUTH] TimeoutException: ${e.message}');
      rethrow;
    } catch (e, s) {
      debugPrint('[AUTH] Unexpected in login: $e\n$s');
      rethrow;
    }
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

    final url = '${_dio.options.baseUrl}${Endpoints.register}';
    debugPrint('[AUTH] POST $url starting');
    try {
      final response = await _dio
          .post(
            Endpoints.register,
            options: Options(headers: {'Authorization': 'Bearer $idToken'}),
            // TODO(TL): align with backend once card_Ea2AwaQhoDTE resolves contract.
            data: {
              'email': email,
              'password': password,
              'firstName': firstName,
              'lastName': lastName,
            },
          )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint('[AUTH] MANUAL TIMEOUT 20s on $url');
        throw TimeoutException('Backend /auth/register no respondió en 20s');
      });
      debugPrint('[AUTH] POST /auth/register status=${response.statusCode}');
      return _parseAuthResponse(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
        '[AUTH] DioException type=${e.type} '
        'status=${e.response?.statusCode} msg=${e.message} error=${e.error}',
      );
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[AUTH] TimeoutException: ${e.message}');
      rethrow;
    } catch (e, s) {
      debugPrint('[AUTH] Unexpected in register: $e\n$s');
      rethrow;
    }
  }

  Future<AuthResult> googleSignIn(String idToken) async {
    final response = await _dio.post(Endpoints.googleAuth, data: {
      'idToken': idToken,
    });
    final googleData = response.data['data'] as Map<String, dynamic>;
    return _parseAuthResponse(googleData, isNewUser: googleData['user']['isNewUser'] as bool? ?? false);
  }

  Future<AuthResult> appleSignIn(String identityToken, String authorizationCode, String? firstName, String? lastName) async {
    final response = await _dio.post(Endpoints.appleAuth, data: {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    });
    final appleData = response.data['data'] as Map<String, dynamic>;
    return _parseAuthResponse(appleData, isNewUser: appleData['user']['isNewUser'] as bool? ?? false);
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
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
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
