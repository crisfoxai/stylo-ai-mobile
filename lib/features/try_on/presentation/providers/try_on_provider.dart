import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/try_on_remote_datasource.dart';

final tryOnDataSourceProvider = Provider<TryOnRemoteDataSource>((ref) {
  return TryOnRemoteDataSource(ref.watch(apiClientProvider));
});

enum TryOnStatus { idle, loading, success, error }

class TryOnState {
  final TryOnStatus status;
  final String? resultUrl;
  final String? errorMessage;

  const TryOnState({
    this.status = TryOnStatus.idle,
    this.resultUrl,
    this.errorMessage,
  });

  TryOnState copyWith({
    TryOnStatus? status,
    String? resultUrl,
    String? errorMessage,
  }) =>
      TryOnState(
        status: status ?? this.status,
        resultUrl: resultUrl ?? this.resultUrl,
        errorMessage: errorMessage,
      );
}

class TryOnNotifier extends StateNotifier<TryOnState> {
  final TryOnRemoteDataSource _dataSource;

  TryOnNotifier(this._dataSource) : super(const TryOnState());

  Future<void> process({
    required String outfitId,
    required File userPhoto,
  }) async {
    state = state.copyWith(status: TryOnStatus.loading, errorMessage: null);
    try {
      final resultUrl = await _dataSource.tryOn(
        outfitId: outfitId,
        userPhoto: userPhoto,
      );
      state = state.copyWith(status: TryOnStatus.success, resultUrl: resultUrl);
    } catch (e) {
      state = state.copyWith(
        status: TryOnStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const TryOnState();
}

final tryOnProvider =
    StateNotifierProvider.autoDispose<TryOnNotifier, TryOnState>((ref) {
  return TryOnNotifier(ref.watch(tryOnDataSourceProvider));
});
