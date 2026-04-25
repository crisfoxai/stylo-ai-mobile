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

    const url = '/auth/session';
    debugPrint('[AUTH] POST ${_dio.options.baseUrl}$url starting');
    try {
      final response = await _dio
          .post(
            url,
            options: Options(headers: {'Authorization': 'Bearer $idToken'}),
            data: {'idToken': idToken!},
          )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint('[AUTH] MANUAL TIMEOUT 20s on $url');
        throw TimeoutException('Backend /auth/session no respondió en 20s');
      });
      debugPrint('[AUTH] POST $url status=${response.statusCode}');
      return _parseAuthResponse(response.data as Map<String, dynamic>, idToken: idToken);
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

    const url = '/auth/session';
    debugPrint('[AUTH] POST ${_dio.options.baseUrl}$url starting');
    try {
      final response = await _dio
          .post(
            url,
            options: Options(headers: {'Authorization': 'Bearer $idToken'}),
            data: {'idToken': idToken!},
          )
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint('[AUTH] MANUAL TIMEOUT 20s on $url');
        throw TimeoutException('Backend /auth/session no respondió en 20s');
      });
      debugPrint('[AUTH] POST $url status=${response.statusCode}');
      return _parseAuthResponse(response.data as Map<String, dynamic>, idToken: idToken, isNewUser: true);
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
    final googleData = response.data as Map<String, dynamic>;
    return _parseAuthResponse(
      googleData,
      isNewUser: (googleData['user'] as Map<String, dynamic>?)?['isNewUser'] as bool? ?? false,
      idToken: idToken,
    );
  }

  Future<AuthResult> appleSignIn(String identityToken, String authorizationCode, String? firstName, String? lastName) async {
    final response = await _dio.post(Endpoints.appleAuth, data: {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    });
    final appleData = response.data as Map<String, dynamic>;
    return _parseAuthResponse(
      appleData,
      isNewUser: (appleData['user'] as Map<String, dynamic>?)?['isNewUser'] as bool? ?? false,
      idToken: identityToken,
    );
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

  AuthResult _parseAuthResponse(
    Map<String, dynamic> data, {
    bool isNewUser = false,
    String? idToken,
  }) {
    final rawUser = data['user'] as Map<String, dynamic>;
    final displayName = (rawUser['displayName'] as String?) ?? '';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final userJson = <String, dynamic>{
      'id': ((rawUser['_id'] ?? rawUser['id']) as Object).toString(),
      'email': (rawUser['email'] as String?) ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': rawUser['photoUrl'] as String?,
      'hasStyleProfile': rawUser['hasStyleProfile'] as bool? ?? false,
      'createdAt': rawUser['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    };

    final user = User.fromJson(userJson);
    final expiresAtStr = data['expiresAt'] as String?;
    final expiresIn = expiresAtStr != null
        ? DateTime.parse(expiresAtStr).difference(DateTime.now()).inSeconds.clamp(0, 7200)
        : 3600;

    return AuthResult(
      user: user,
      accessToken: idToken ?? '',
      refreshToken: '',
      expiresIn: expiresIn,
      isNewUser: isNewUser,
    );
  }
}
