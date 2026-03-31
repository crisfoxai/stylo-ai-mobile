import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<SubscriptionModel> getStatus() async {
    final response = await _dio.get(Endpoints.subscription);
    return SubscriptionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<SubscriptionModel> verifyPurchase({
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
    return SubscriptionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
