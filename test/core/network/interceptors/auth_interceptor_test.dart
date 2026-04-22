import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylo_ai/core/network/interceptors/auth_interceptor.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _MockFirebaseAuth mockAuth;
  late _MockUser mockUser;

  setUp(() {
    mockAuth = _MockFirebaseAuth();
    mockUser = _MockUser();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  AuthInterceptor makeInterceptor() {
    late AuthInterceptor result;
    container.read(Provider<void>((ref) {
      result = AuthInterceptor(ref, auth: mockAuth);
    }));
    return result;
  }

  group('AuthInterceptor', () {
    test('is an Interceptor subclass', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(makeInterceptor(), isA<Interceptor>());
    });

    test('onRequest calls handler.next so the request continues', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final interceptor = makeInterceptor();
      final options = RequestOptions(path: '/test');

      bool nextCalled = false;
      interceptor.onRequest(
        options,
        _TestRequestHandler(onNext: (_) => nextCalled = true),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect(nextCalled, isTrue);
    });

    test('onRequest does not add Authorization header when no user', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final interceptor = makeInterceptor();
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

    test('onRequest adds Authorization header when user has token', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.getIdToken()).thenAnswer((_) async => 'test-token-123');
      final interceptor = makeInterceptor();
      final options = RequestOptions(path: '/test');

      RequestOptions? capturedOptions;
      interceptor.onRequest(
        options,
        _TestRequestHandler(onNext: (opts) => capturedOptions = opts),
      );

      await Future.delayed(const Duration(milliseconds: 200));
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.headers['Authorization'], equals('Bearer test-token-123'));
    });

    test('onError passes through non-401 errors via handler.next', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final interceptor = makeInterceptor();
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

    test('onError handles 401 gracefully when no user is authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final interceptor = makeInterceptor();
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
