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

    return _syncWithBackend(idToken!, isNewUser: false);
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

    return _syncWithBackend(idToken!, isNewUser: true);
  }

  /// POST /auth/session to sync user in DB; Firebase ID token is the sole auth mechanism.
  Future<AuthResult> _syncWithBackend(String idToken, {required bool isNewUser}) async {
    debugPrint('[AUTH] POST ${Endpoints.authSession}');
    try {
      final response = await _dio
          .post(
            Endpoints.authSession,
            options: Options(headers: {'Authorization': 'Bearer $idToken'}),
            data: {'idToken': idToken},
          )
          .timeout(const Duration(seconds: 20));
      debugPrint('[AUTH] session sync status=${response.statusCode}');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return _parseAuthResponse(data, idToken: idToken, isNewUser: isNewUser);
    } on DioException catch (e) {
      debugPrint('[AUTH] session sync error=${e.response?.statusCode} msg=${e.message}');
      // If backend is unavailable, build user from Firebase profile
      if (e.response?.statusCode == null || e.response!.statusCode! >= 500) {
        return _fallbackFromFirebase(idToken, isNewUser: isNewUser);
      }
      rethrow;
    }
  }

  /// Build an AuthResult from the Firebase user when backend is unreachable.
  AuthResult _fallbackFromFirebase(String idToken, {required bool isNewUser}) {
    final fbUser = _firebaseAuth.currentUser!;
    final displayName = fbUser.displayName ?? '';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return AuthResult(
      user: User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        firstName: parts.isNotEmpty ? parts.first : '',
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        hasStyleProfile: false,
        createdAt: DateTime.now(),
      ),
      accessToken: idToken,
      refreshToken: '',
      expiresIn: 3600,
      isNewUser: isNewUser,
    );
  }

  Future<AuthResult> googleSignIn(String googleIdToken, {String? accessToken}) async {
    debugPrint('[AUTH] Google Firebase credential sign-in start');
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleIdToken,
      accessToken: accessToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    debugPrint('[AUTH] Google Firebase sign-in ok, uid=${userCredential.user!.uid}');

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    final firebaseIdToken = await userCredential.user!.getIdToken();
    debugPrint('[AUTH] Firebase idToken length=${firebaseIdToken?.length ?? 0}');

    return _syncWithBackend(firebaseIdToken!, isNewUser: isNewUser);
  }

  Future<AuthResult> appleSignIn(
    String identityToken,
    String authorizationCode,
    String? firstName,
    String? lastName,
  ) async {
    final response = await _dio.post(Endpoints.appleAuth, data: {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
    });
    final body = response.data as Map<String, dynamic>;
    final appleData = body['data'] as Map<String, dynamic>? ?? body;
    return _parseAuthResponse(
      appleData,
      isNewUser: (appleData['user'] as Map<String, dynamic>?)?['isNewUser'] as bool? ?? false,
      idToken: identityToken,
    );
  }

  Future<void> logout(String refreshToken) async {
    // Firebase sign-out is sufficient; backend logout is best-effort.
    try {
      await _dio.post(Endpoints.logout, data: {'refreshToken': refreshToken});
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  AuthResult _parseAuthResponse(
    Map<String, dynamic> data, {
    bool isNewUser = false,
    String? idToken,
  }) {
    final rawUser = data['user'] as Map<String, dynamic>? ?? data;
    final displayName = (rawUser['displayName'] as String?) ?? '';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final userJson = <String, dynamic>{
      'id': ((rawUser['_id'] ?? rawUser['id']) as Object?)?.toString() ?? '',
      'email': (rawUser['email'] as String?) ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': rawUser['photoUrl'] as String?,
      'hasStyleProfile': rawUser['hasStyleProfile'] as bool? ?? false,
      'createdAt': rawUser['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    };

    final user = User.fromJson(userJson);

    // Railway: no backend tokens — Firebase ID token is the sole credential.
    return AuthResult(
      user: user,
      accessToken: idToken ?? '',
      refreshToken: '',
      expiresIn: 3600,
      isNewUser: isNewUser,
    );
  }
}
