class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Extracts a user-friendly message from any caught exception.
  /// Handles AppException, DioException (which wraps AppException after
  /// ErrorInterceptor sets message = exception.message), and generic errors.
  static String extractMessage(dynamic e) {
    if (e is AppException) return e.message;
    // DioException.message is set to AppException.message by ErrorInterceptor.
    // Access via dynamic to avoid importing package:dio here.
    try {
      final msg = (e as dynamic).message as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    return e.toString();
  }
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode, super.originalError});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'No autorizado', super.statusCode = 401});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Acceso denegado', super.statusCode = 403});
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'No encontrado', super.statusCode = 404});
}

class ValidationException extends AppException {
  final List<FieldError> fieldErrors;
  const ValidationException({
    super.message = 'Error de validación',
    super.statusCode = 400,
    this.fieldErrors = const [],
  });
}

class FieldError {
  final String field;
  final String message;
  const FieldError({required this.field, required this.message});
}

class ServerException extends AppException {
  const ServerException({super.message = 'Error del servidor', super.statusCode = 500});
}

class NoInternetException extends AppException {
  const NoInternetException({super.message = 'Sin conexión a internet'});
}

class RateLimitException extends AppException {
  const RateLimitException({super.message = 'Demasiadas solicitudes. Intentá más tarde.', super.statusCode = 429});
}
