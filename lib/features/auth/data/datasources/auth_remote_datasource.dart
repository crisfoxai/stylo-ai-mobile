import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResult> login(String email, String password) async {
    final response = await _dio.post(Endpoints.login, data: {
      'email': email,
      'password': password,
    });
    return _parseAuthResponse(response.data['data']);
  }

  Future<AuthResult> register(String email, String password, String firstName, String lastName) async {
    final response = await _dio.post(Endpoints.register, data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    });
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
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(Endpoints.forgotPassword, data: {'email': email});
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
