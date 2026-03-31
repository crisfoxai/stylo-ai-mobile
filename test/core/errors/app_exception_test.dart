import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('creates with required message', () {
      const exception = AppException(message: 'Something went wrong');
      expect(exception.message, 'Something went wrong');
    });

    test('statusCode is null by default', () {
      const exception = AppException(message: 'error');
      expect(exception.statusCode, isNull);
    });

    test('originalError is null by default', () {
      const exception = AppException(message: 'error');
      expect(exception.originalError, isNull);
    });

    test('creates with statusCode', () {
      const exception = AppException(message: 'error', statusCode: 500);
      expect(exception.statusCode, 500);
    });

    test('creates with originalError', () {
      final original = Exception('original');
      final exception = AppException(message: 'error', originalError: original);
      expect(exception.originalError, original);
    });

    test('toString includes statusCode and message', () {
      const exception = AppException(message: 'error detail', statusCode: 400);
      expect(exception.toString(), 'AppException(400): error detail');
    });

    test('toString with null statusCode', () {
      const exception = AppException(message: 'error detail');
      expect(exception.toString(), 'AppException(null): error detail');
    });

    test('is an Exception', () {
      const exception = AppException(message: 'error');
      expect(exception, isA<Exception>());
    });
  });

  group('NetworkException', () {
    test('creates with required message', () {
      const exception = NetworkException(message: 'Network error');
      expect(exception.message, 'Network error');
    });

    test('is an AppException', () {
      const exception = NetworkException(message: 'error');
      expect(exception, isA<AppException>());
    });

    test('creates with statusCode', () {
      const exception = NetworkException(message: 'error', statusCode: 503);
      expect(exception.statusCode, 503);
    });

    test('creates with originalError', () {
      final original = Exception('timeout');
      final exception = NetworkException(message: 'error', originalError: original);
      expect(exception.originalError, original);
    });
  });

  group('UnauthorizedException', () {
    test('has default message in Spanish', () {
      const exception = UnauthorizedException();
      expect(exception.message, 'No autorizado');
    });

    test('has default status code 401', () {
      const exception = UnauthorizedException();
      expect(exception.statusCode, 401);
    });

    test('is an AppException', () {
      const exception = UnauthorizedException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = UnauthorizedException(message: 'Custom unauthorized');
      expect(exception.message, 'Custom unauthorized');
    });
  });

  group('ForbiddenException', () {
    test('has default message in Spanish', () {
      const exception = ForbiddenException();
      expect(exception.message, 'Acceso denegado');
    });

    test('has default status code 403', () {
      const exception = ForbiddenException();
      expect(exception.statusCode, 403);
    });

    test('is an AppException', () {
      const exception = ForbiddenException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = ForbiddenException(message: 'Custom forbidden');
      expect(exception.message, 'Custom forbidden');
    });
  });

  group('NotFoundException', () {
    test('has default message in Spanish', () {
      const exception = NotFoundException();
      expect(exception.message, 'No encontrado');
    });

    test('has default status code 404', () {
      const exception = NotFoundException();
      expect(exception.statusCode, 404);
    });

    test('is an AppException', () {
      const exception = NotFoundException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = NotFoundException(message: 'User not found');
      expect(exception.message, 'User not found');
    });
  });

  group('ValidationException', () {
    test('has default message in Spanish', () {
      const exception = ValidationException();
      expect(exception.message, 'Error de validación');
    });

    test('has default status code 400', () {
      const exception = ValidationException();
      expect(exception.statusCode, 400);
    });

    test('is an AppException', () {
      const exception = ValidationException();
      expect(exception, isA<AppException>());
    });

    test('fieldErrors is empty by default', () {
      const exception = ValidationException();
      expect(exception.fieldErrors, isEmpty);
    });

    test('creates with field errors', () {
      const exception = ValidationException(
        fieldErrors: [
          FieldError(field: 'email', message: 'Invalid email'),
          FieldError(field: 'password', message: 'Too short'),
        ],
      );
      expect(exception.fieldErrors.length, 2);
      expect(exception.fieldErrors[0].field, 'email');
      expect(exception.fieldErrors[0].message, 'Invalid email');
      expect(exception.fieldErrors[1].field, 'password');
      expect(exception.fieldErrors[1].message, 'Too short');
    });
  });

  group('FieldError', () {
    test('creates with field and message', () {
      const error = FieldError(field: 'email', message: 'Invalid');
      expect(error.field, 'email');
      expect(error.message, 'Invalid');
    });
  });

  group('ServerException', () {
    test('has default message in Spanish', () {
      const exception = ServerException();
      expect(exception.message, 'Error del servidor');
    });

    test('has default status code 500', () {
      const exception = ServerException();
      expect(exception.statusCode, 500);
    });

    test('is an AppException', () {
      const exception = ServerException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = ServerException(message: 'Custom server error');
      expect(exception.message, 'Custom server error');
    });
  });

  group('NoInternetException', () {
    test('has default message in Spanish', () {
      const exception = NoInternetException();
      expect(exception.message, 'Sin conexión a internet');
    });

    test('statusCode is null by default', () {
      const exception = NoInternetException();
      expect(exception.statusCode, isNull);
    });

    test('is an AppException', () {
      const exception = NoInternetException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = NoInternetException(message: 'No internet');
      expect(exception.message, 'No internet');
    });
  });

  group('RateLimitException', () {
    test('has default message in Spanish', () {
      const exception = RateLimitException();
      expect(exception.message, 'Demasiadas solicitudes. Intentá más tarde.');
    });

    test('has default status code 429', () {
      const exception = RateLimitException();
      expect(exception.statusCode, 429);
    });

    test('is an AppException', () {
      const exception = RateLimitException();
      expect(exception, isA<AppException>());
    });

    test('allows custom message', () {
      const exception = RateLimitException(message: 'Rate limited');
      expect(exception.message, 'Rate limited');
    });
  });

  group('Exception hierarchy', () {
    test('all exceptions extend AppException', () {
      expect(const NetworkException(message: 'e'), isA<AppException>());
      expect(const UnauthorizedException(), isA<AppException>());
      expect(const ForbiddenException(), isA<AppException>());
      expect(const NotFoundException(), isA<AppException>());
      expect(const ValidationException(), isA<AppException>());
      expect(const ServerException(), isA<AppException>());
      expect(const NoInternetException(), isA<AppException>());
      expect(const RateLimitException(), isA<AppException>());
    });

    test('all exceptions implement Exception', () {
      expect(const AppException(message: 'e'), isA<Exception>());
      expect(const NetworkException(message: 'e'), isA<Exception>());
      expect(const UnauthorizedException(), isA<Exception>());
      expect(const ForbiddenException(), isA<Exception>());
      expect(const NotFoundException(), isA<Exception>());
      expect(const ValidationException(), isA<Exception>());
      expect(const ServerException(), isA<Exception>());
      expect(const NoInternetException(), isA<Exception>());
      expect(const RateLimitException(), isA<Exception>());
    });
  });
}
