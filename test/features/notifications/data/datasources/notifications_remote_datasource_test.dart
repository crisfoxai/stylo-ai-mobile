import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/features/notifications/data/datasources/notifications_remote_datasource.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late NotificationsRemoteDataSource dataSource;
  late _MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    dataSource = NotificationsRemoteDataSource(mockDio);
  });

  group('NotificationsRemoteDataSource', () {
    test('registerToken sends POST with token and platform', () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      await dataSource.registerToken('fcm-token-123', 'android');

      verify(
        () => mockDio.post(
          '/notifications/register-token',
          data: {'token': 'fcm-token-123', 'platform': 'android'},
        ),
      ).called(1);
    });

    test('unregisterToken sends DELETE with token', () async {
      when(
        () => mockDio.delete(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      await dataSource.unregisterToken('fcm-token-123');

      verify(
        () => mockDio.delete(
          '/notifications/register-token',
          data: {'token': 'fcm-token-123'},
        ),
      ).called(1);
    });
  });
}
