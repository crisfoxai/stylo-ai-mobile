import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';

/// A simple provider used solely to obtain a [Ref] for testing.
final _testProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref);
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();

    // Mock the FlutterSecureStorage method channel so reads return null
    // and writes/deletes succeed silently.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            return null;
          case 'write':
          case 'delete':
          case 'deleteAll':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
  });

  group('AuthInterceptor', () {
    test('is an Interceptor subclass', () {
      final interceptor = container.read(_testProvider);
      expect(interceptor, isA<Interceptor>());
    });

    test('can be instantiated via a Riverpod provider', () {
      expect(() => container.read(_testProvider), returnsNormally);
    });

    test('onRequest calls handler.next so the request continues', () async {
      final interceptor = container.read(_testProvider);
      final options = RequestOptions(path: '/test');

      bool nextCalled = false;
      interceptor.onRequest(
        options,
        _TestRequestHandler(onNext: (_) => nextCalled = true),
      );

      // Allow the async storage read inside onRequest to complete
      await Future.delayed(const Duration(milliseconds: 200));
      expect(nextCalled, isTrue);
    });

    test('onRequest does not add Authorization header when no token', () async {
      final interceptor = container.read(_testProvider);
      final options = RequestOptions(path: '/test');

      RequestOptions? capturedOptions;
      interceptor.onRequest(
        options,
        _TestRequestHandler(onNext: (opts) => capturedOptions = opts),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.headers.containsKey('Authorization'), isFalse);
    });

    test('onError passes through non-401 errors via handler.next', () async {
      final interceptor = container.read(_testProvider);
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      bool nextCalled = false;
      interceptor.onError(
        dioError,
        _TestErrorHandler(onNext: (_) => nextCalled = true),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect(nextCalled, isTrue);
    });

    test('onError handles 401 gracefully when no refresh token exists', () async {
      final interceptor = container.read(_testProvider);
      final requestOptions = RequestOptions(path: '/test');
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      bool handlerInvoked = false;
      interceptor.onError(
        dioError,
        _TestErrorHandler(
          onNext: (_) => handlerInvoked = true,
          onResolve: (_) => handlerInvoked = true,
        ),
      );

      // Allow the async refresh flow to complete
      await Future.delayed(const Duration(milliseconds: 500));
      expect(handlerInvoked, isTrue);
    });
  });
}

class _TestRequestHandler extends RequestInterceptorHandler {
  final void Function(RequestOptions) onNext;

  _TestRequestHandler({required this.onNext});

  @override
  void next(RequestOptions requestOptions) {
    onNext(requestOptions);
  }
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException)? onNext;
  final void Function(Response)? onResolve;

  _TestErrorHandler({this.onNext, this.onResolve});

  @override
  void next(DioException err) {
    onNext?.call(err);
  }

  @override
  void resolve(Response response) {
    onResolve?.call(response);
  }
}
