import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/errors/failure.dart';

void main() {
  group('Failure hierarchy', () {
    test('NetworkFailure has default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Error de red');
    });

    test('NetworkFailure accepts custom message', () {
      const failure = NetworkFailure('Custom network error');
      expect(failure.message, 'Custom network error');
    });

    test('AuthFailure has default message', () {
      const failure = AuthFailure();
      expect(failure.message, 'Error de autenticación');
    });

    test('ServerFailure has default message', () {
      const failure = ServerFailure();
      expect(failure.message, 'Error del servidor');
    });

    test('CacheFailure has default message', () {
      const failure = CacheFailure();
      expect(failure.message, 'Error de caché');
    });

    test('ValidationFailure has default message', () {
      const failure = ValidationFailure();
      expect(failure.message, 'Error de validación');
    });

    test('equality works via Equatable', () {
      const a = NetworkFailure('err');
      const b = NetworkFailure('err');
      const c = NetworkFailure('other');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('props returns message', () {
      const failure = AuthFailure('test');
      expect(failure.props, ['test']);
    });

    test('different types with same message are not equal', () {
      const network = NetworkFailure('error');
      const server = ServerFailure('error');
      expect(network, isNot(equals(server)));
    });
  });
}
