import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/wardrobe_remote_datasource.dart';
import '../../data/repositories/wardrobe_repository_impl.dart';
import '../../domain/entities/garment.dart';
import '../../domain/repositories/wardrobe_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepositoryImpl(
    WardrobeRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

// ─── Wardrobe State ──────────────────────────────────────────────────────────

class WardrobeState {
  final List<Garment> garments;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final int total;
  final String? activeFilter;
  final String searchQuery;

  const WardrobeState({
    this.garments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.total = 0,
    this.activeFilter,
    this.searchQuery = '',
  });

  WardrobeState copyWith({
    List<Garment>? garments,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    int? total,
    String? activeFilter,
    String? searchQuery,
    bool clearError = false,
    bool clearFilter = false,
  }) =>
      WardrobeState(
        garments: garments ?? this.garments,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        total: total ?? this.total,
        activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

// ─── Wardrobe Notifier ───────────────────────────────────────────────────────

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final WardrobeRepository _repository;
  static const int _pageSize = 20;

  WardrobeNotifier(this._repository) : super(const WardrobeState());

  Map<String, dynamic>? get _activeFilters {
    final filter = state.activeFilter;
    if (filter == null || filter.isEmpty) return null;
    return {'type': filter};
  }

  Future<void> loadGarments({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: refresh ? 1 : state.currentPage,
      garments: refresh ? [] : state.garments,
    );

    try {
      final result = await _repository.getGarments(
        page: 1,
        limit: _pageSize,
        filters: _activeFilters,
      );

      state = state.copyWith(
        garments: result.items,
        isLoading: false,
        currentPage: 1,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getGarments(
        page: nextPage,
        limit: _pageSize,
        filters: _activeFilters,
      );

      state = state.copyWith(
        garments: [...state.garments, ...result.items],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setFilter(String? filter) async {
    if (state.activeFilter == filter) return;
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(activeFilter: filter);
    }
    await loadGarments(refresh: true);
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await loadGarments(refresh: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await _repository.searchGarments(query);
      state = state.copyWith(
        garments: results,
        isLoading: false,
        hasMore: false,
        total: results.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteGarment(String id) async {
    await _repository.deleteGarment(id);
    state = state.copyWith(
      garments: state.garments.where((g) => g.id != id).toList(),
      total: state.total - 1,
    );
  }

  void addGarment(Garment garment) {
    state = state.copyWith(
      garments: [garment, ...state.garments],
      total: state.total + 1,
    );
  }
}

// ─── Scan State ──────────────────────────────────────────────────────────────

enum ScanStep { idle, capturing, uploading, processing, done, error }

class ScanState {
  final ScanStep step;
  final String? imagePath;
  final String? jobId;
  final Garment? result;
  final String? errorMessage;

  const ScanState({
    this.step = ScanStep.idle,
    this.imagePath,
    this.jobId,
    this.result,
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStep? step,
    String? imagePath,
    String? jobId,
    Garment? result,
    String? errorMessage,
  }) =>
      ScanState(
        step: step ?? this.step,
        imagePath: imagePath ?? this.imagePath,
        jobId: jobId ?? this.jobId,
        result: result ?? this.result,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class GarmentScanNotifier extends StateNotifier<ScanState> {
  final WardrobeRepository _repository;
  Timer? _pollingTimer;

  GarmentScanNotifier(this._repository) : super(const ScanState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void setImagePath(String path) {
    state = ScanState(imagePath: path, step: ScanStep.capturing);
  }

  Future<void> startScan(String imagePath) async {
    state = ScanState(imagePath: imagePath, step: ScanStep.uploading);

    try {
      final jobResult = await _repository.scanGarment(imagePath);
      state = state.copyWith(jobId: jobResult.jobId, step: ScanStep.processing);
      _startPolling(jobResult.jobId);
    } catch (e) {
      state = state.copyWith(
        step: ScanStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _startPolling(String jobId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted) {
        _pollingTimer?.cancel();
        return;
      }
      await _checkJob(jobId);
    });
  }

  Future<void> _checkJob(String jobId) async {
    try {
      final status = await _repository.checkScanJob(jobId);
      if (!mounted) return;

      if (status.isComplete && status.garment != null) {
        _pollingTimer?.cancel();
        state = state.copyWith(
          step: ScanStep.done,
          result: status.garment,
        );
      } else if (status.isFailed) {
        _pollingTimer?.cancel();
        state = state.copyWith(
          step: ScanStep.error,
          errorMessage: status.errorMessage ?? 'Scan failed',
        );
      }
    } catch (e) {
      _pollingTimer?.cancel();
      if (!mounted) return;
      state = state.copyWith(
        step: ScanStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    _pollingTimer?.cancel();
    state = const ScanState();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final wardrobeNotifierProvider =
    StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier(ref.watch(wardrobeRepositoryProvider));
});

final garmentScanProvider =
    StateNotifierProvider<GarmentScanNotifier, ScanState>((ref) {
  return GarmentScanNotifier(ref.watch(wardrobeRepositoryProvider));
});

final filteredWardrobeProvider = Provider<List<Garment>>((ref) {
  final state = ref.watch(wardrobeNotifierProvider);
  final query = state.searchQuery.toLowerCase();

  if (query.isEmpty) return state.garments;

  return state.garments.where((g) {
    return g.name.toLowerCase().contains(query) ||
        g.type.toLowerCase().contains(query) ||
        (g.color?.toLowerCase().contains(query) ?? false) ||
        g.tags.any((t) => t.toLowerCase().contains(query));
  }).toList();
});

final garmentDetailProvider =
    FutureProvider.family<Garment, String>((ref, id) {
  return ref.watch(wardrobeRepositoryProvider).getGarment(id);
});
