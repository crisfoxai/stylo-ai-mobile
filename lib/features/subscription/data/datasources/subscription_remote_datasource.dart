import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<Subscription> getStatus() async {
    final response = await _dio.get(Endpoints.subscription);
    return Subscription.fromJson(_normalize(response.data as Map));
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
    return Subscription.fromJson(_normalize(response.data as Map));
  }

  static Map<String, dynamic> _normalize(Map raw) {
    final data = Map<String, dynamic>.from(raw);
    // Mongoose lean() returns _id; entity expects id
    if (!data.containsKey('id') && data.containsKey('_id')) {
      data['id'] = data['_id'].toString();
    }
    return data;
  }
}
