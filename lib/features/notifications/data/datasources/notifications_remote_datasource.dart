import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSource(this._dio);

  Future<void> registerToken(String token, String platform) async {
    await _dio.post(
      Endpoints.registerPushToken,
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterToken(String token) async {
    await _dio.delete(
      Endpoints.registerPushToken,
      data: {'token': token},
    );
  }
}
