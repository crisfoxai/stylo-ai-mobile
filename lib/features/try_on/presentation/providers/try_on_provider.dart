import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/try_on_remote_datasource.dart';
import '../../domain/entities/try_on_result.dart';

final tryOnDataSourceProvider = Provider<TryOnRemoteDataSource>((ref) {
  return TryOnRemoteDataSource(ref.watch(apiClientProvider));
});

enum TryOnStatus { idle, uploading, processing, done, error }

class TryOnState {
  final TryOnStatus status;
  final String? imagePath;
  final String? garmentId;
  final TryOnResult? result;
  final String? errorMessage;

  const TryOnState({
    this.status = TryOnStatus.idle,
    this.imagePath,
    this.garmentId,
    this.result,
    this.errorMessage,
  });

  TryOnState copyWith({
    TryOnStatus? status,
    String? imagePath,
    String? garmentId,
    TryOnResult? result,
    String? errorMessage,
    bool clearError = false,
  }) =>
      TryOnState(
        status: status ?? this.status,
        imagePath: imagePath ?? this.imagePath,
        garmentId: garmentId ?? this.garmentId,
        result: result ?? this.result,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  String? get resultUrl => result?.resultUrl;
}

class TryOnNotifier extends StateNotifier<TryOnState> {
  final TryOnRemoteDataSource _dataSource;

  TryOnNotifier(this._dataSource) : super(const TryOnState());

  Future<void> startTryOn(String imagePath, String garmentId) async {
    state = state.copyWith(
      status: TryOnStatus.uploading,
      imagePath: imagePath,
      garmentId: garmentId,
      clearError: true,
    );
    try {
      // Uploading → processing transition for UX feedback
      state = state.copyWith(status: TryOnStatus.processing);
      final result = await _dataSource.startTryOn(
        imagePath: imagePath,
        garmentId: garmentId,
      );
      state = state.copyWith(status: TryOnStatus.done, result: result);
    } catch (e) {
      state = state.copyWith(
        status: TryOnStatus.error,
        errorMessage: _parseError(e),
      );
    }
  }

  void reset() => state = const TryOnState();

  String _parseError(Object e) {
    if (e is DioException) {
      final body = e.response?.data;
      if (body is Map) {
        if (body['error'] == 'PLAN_LIMIT') {
          final limit = body['limit'] ?? 20;
          return 'Alcanzaste el límite de $limit try-ons de tu plan';
        }
        if (body['error'] == 'TRYON_UNAVAILABLE') {
          return 'El servicio de try-on no está disponible ahora. Intentá más tarde.';
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'La generación tardó demasiado. Intentá de nuevo.';
      }
    }
    return 'Error al generar el try-on';
  }
}

final tryOnProvider =
    StateNotifierProvider.autoDispose<TryOnNotifier, TryOnState>((ref) {
  return TryOnNotifier(ref.watch(tryOnDataSourceProvider));
});
