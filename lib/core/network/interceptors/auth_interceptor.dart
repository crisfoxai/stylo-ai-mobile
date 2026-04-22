import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final FirebaseAuth _auth;

  AuthInterceptor(this._ref, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
      } catch (_) {
        // If token fetch fails, proceed without auth header
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          // Force-refresh the Firebase ID token once
          final freshToken = await user.getIdToken(true);
          err.requestOptions.headers['Authorization'] = 'Bearer $freshToken';
          final retryDio = Dio(
            BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              headers: err.requestOptions.headers,
            ),
          );
          final retryResponse = await retryDio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          // Refresh failed — sign out; authStateProvider stream handles redirect
          await _auth.signOut();
        }
      }
    }
    handler.next(err);
  }
}
