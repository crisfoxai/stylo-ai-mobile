import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:stylo_ai/features/subscription/domain/entities/subscription.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio mockDio;
  late SubscriptionRemoteDataSource dataSource;

  Response<dynamic> fakeOk(Map<String, dynamic> data) => Response(
        data: data,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

  setUp(() {
    mockDio = _MockDio();
    dataSource = SubscriptionRemoteDataSource(mockDio);
  });

  group('SubscriptionRemoteDataSource', () {
    group('getStatus', () {
      test('returns free subscription from response', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => fakeOk({'_id': 'sub1', 'plan': 'free', 'status': 'active'}),
        );

        final result = await dataSource.getStatus();

        expect(result.id, 'sub1');
        expect(result.plan, SubscriptionPlan.free);
        expect(result.status, SubscriptionStatus.active);
      });
    });

    group('verifyPurchase', () {
      test('returns premium subscription after verification', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => fakeOk({'_id': 'sub2', 'plan': 'pro', 'status': 'active'}),
        );

        final result = await dataSource.verifyPurchase(
          productId: 'stylo_premium_monthly',
          receiptData: 'receipt_abc',
          platform: 'ios',
        );

        expect(result.plan, SubscriptionPlan.pro);
        expect(result.status, SubscriptionStatus.active);
      });
    });
  });
}
