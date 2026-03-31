import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/errors/app_exception.dart';
import 'package:stylo_ai/core/network/interceptors/error_interceptor.dart';

void main() {
  late ErrorInterceptor interceptor;
  late RequestOptions requestOptions;

  setUp(() {
    interceptor = ErrorInterceptor();
    requestOptions = RequestOptions(path: '/test');
  });

  group('ErrorInterceptor - onError', () {
    test('maps timeout DioExceptionTypes to NetworkException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final dioError = DioException(
          requestOptions: requestOptions,
          type: type,
        );

        late DioException result;
        interceptor.onError(
          dioError,
          _TestErrorHandler(onNext: (e) => result = e),
        );

        expect(result.error, isA<NetworkException>());
        final networkErr = result.error as NetworkException;
        expect(networkErr.message, 'Tiempo de espera agotado');
        expect(networkErr.statusCode, 408);
      }
    });

    test('maps SocketException to NoInternetException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
        error: const SocketException('No route to host'),
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<NoInternetException>());
    });

    test('maps 401 response to UnauthorizedException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {
            'error': {'message': 'Token expired'}
          },
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<UnauthorizedException>());
      expect((result.error as UnauthorizedException).message, 'Token expired');
    });

    test('maps 404 response to NotFoundException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 404,
          data: {
            'error': {'message': 'Resource not found'}
          },
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<NotFoundException>());
      expect((result.error as NotFoundException).message, 'Resource not found');
    });

    test('maps 400 response to ValidationException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 400,
          data: {
            'error': {'message': 'Invalid email format'}
          },
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<ValidationException>());
      expect(
          (result.error as ValidationException).message, 'Invalid email format');
    });

    test('maps 429 response to RateLimitException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 429,
          data: {
            'error': {'message': 'Too many requests'}
          },
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<RateLimitException>());
    });

    test('maps 500 response to ServerException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 500,
          data: {
            'error': {'message': 'Internal server error'}
          },
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<ServerException>());
      expect((result.error as ServerException).statusCode, 500);
    });

    test('maps unknown error without response to NetworkException', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
        message: 'Something failed',
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<NetworkException>());
      expect((result.error as NetworkException).message, 'Something failed');
    });

    test('uses default message when response data is not a Map', () {
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 403,
          data: 'plain text error',
        ),
        type: DioExceptionType.badResponse,
      );

      late DioException result;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (e) => result = e),
      );

      expect(result.error, isA<ForbiddenException>());
      expect(
          (result.error as ForbiddenException).message, 'Error desconocido');
    });
  });
}

/// A minimal test implementation of [ErrorInterceptorHandler] that captures
/// the error passed to [next].
class _TestErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException) onNext;

  _TestErrorHandler({required this.onNext});

  @override
  void next(DioException err) {
    onNext(err);
  }
}
