import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth;

  AuthInterceptor(Ref ref) : _auth = ref.read(firebaseAuthProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _auth.currentUser?.getIdToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final firebaseUser = _auth.currentUser;
        if (firebaseUser == null) throw Exception('no_user');

        final newToken = await firebaseUser.getIdToken(true);
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        final retryDio = Dio(
          BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            headers: err.requestOptions.headers,
          ),
        );
        final retryResponse = await retryDio.fetch<dynamic>(err.requestOptions);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        await _auth.signOut();
      }
    }
    handler.next(err);
  }
}
