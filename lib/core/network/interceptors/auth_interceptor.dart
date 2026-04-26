import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';
import '../endpoints.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  late final FirebaseAuth _auth;
  late final FlutterSecureStorage _storage;

  AuthInterceptor(this._ref, {FirebaseAuth? auth, FlutterSecureStorage? storage}) {
    _auth = auth ?? _ref.read(firebaseAuthProvider);
    _storage = storage ?? _ref.read(_secureStorageProvider);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: StorageKeys.accessToken);
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
        String? newToken;

        // Strategy 1: Firebase token refresh (Railway — Firebase ID token is the bearer)
        final firebaseUser = _auth.currentUser;
        if (firebaseUser != null) {
          newToken = await firebaseUser.getIdToken(true);
        }

        // Strategy 2: backend refresh token (local Docker — backend JWT pair)
        if (newToken == null || newToken.isEmpty) {
          final storedRefresh = await _storage.read(key: StorageKeys.refreshToken);
          if (storedRefresh != null) {
            final refreshDio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
            final refreshResp = await refreshDio.post(
              Endpoints.refreshToken,
              data: {'refreshToken': storedRefresh},
            );
            final raw = refreshResp.data;
            final data = (raw is Map && raw.containsKey('data'))
                ? raw['data'] as Map<String, dynamic>
                : raw as Map<String, dynamic>;
            newToken = data['accessToken'] as String?;
            final newRefresh = data['refreshToken'] as String?;
            if (newRefresh != null) {
              await _storage.write(key: StorageKeys.refreshToken, value: newRefresh);
            }
          }
        }

        if (newToken == null || newToken.isEmpty) throw Exception('token_refresh_failed');

        await _storage.write(key: StorageKeys.accessToken, value: newToken);
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
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
        await _storage.deleteAll();
        await _auth.signOut();
      }
    }
    handler.next(err);
  }
}
