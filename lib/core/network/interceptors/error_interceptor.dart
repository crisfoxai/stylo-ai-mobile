import 'dart:io';
import 'package:dio/dio.dart';
import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException exception;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      exception = const NetworkException(
        message: 'Tiempo de espera agotado',
        statusCode: 408,
      );
    } else if (err.error is SocketException) {
      exception = const NoInternetException();
    } else if (err.response != null) {
      final statusCode = err.response!.statusCode ?? 500;
      final data = err.response!.data;
      final message = data is Map ? (data['error']?['message'] ?? 'Error desconocido') as String : 'Error desconocido';

      exception = switch (statusCode) {
        400 => ValidationException(message: message),
        401 => UnauthorizedException(message: message),
        403 => ForbiddenException(message: message),
        404 => NotFoundException(message: message),
        429 => RateLimitException(message: message),
        _ => ServerException(message: message, statusCode: statusCode),
      };
    } else {
      exception = NetworkException(
        message: err.message ?? 'Error de conexión',
        originalError: err,
      );
    }

    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      response: err.response,
      type: err.type,
    ));
  }
}
