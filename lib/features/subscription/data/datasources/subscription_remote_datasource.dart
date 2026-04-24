import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<Subscription> getStatus() async {
    final response = await _dio.get(Endpoints.subscription);
    return Subscription.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Subscription> verifyPurchase({
    required String productId,
    required String receiptData,
    required String platform,
  }) async {
    final response = await _dio.post(
      Endpoints.verifyPurchase,
      data: {
        'productId': productId,
        'receiptData': receiptData,
        'platform': platform,
      },
    );
    return Subscription.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
