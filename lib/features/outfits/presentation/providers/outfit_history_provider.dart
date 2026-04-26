import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/repositories/outfit_repository.dart';
import 'outfit_generator_provider.dart';

class OutfitHistoryState {
  final List<Outfit> outfits;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;

  const OutfitHistoryState({
    this.outfits = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  OutfitHistoryState copyWith({
    List<Outfit>? outfits,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
  }) {
    return OutfitHistoryState(
      outfits: outfits ?? this.outfits,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class OutfitHistoryNotifier extends StateNotifier<OutfitHistoryState> {
  final OutfitRepository _repository;
  static const int _pageSize = 20;

  OutfitHistoryNotifier(this._repository) : super(const OutfitHistoryState()) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final outfits =
          await _repository.getHistory(page: 1, limit: _pageSize);
      state = state.copyWith(
        outfits: outfits,
        isLoading: false,
        currentPage: 1,
        hasMore: outfits.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final outfits =
          await _repository.getHistory(page: nextPage, limit: _pageSize);
      state = state.copyWith(
        outfits: [...state.outfits, ...outfits],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: outfits.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => load();
}

final outfitHistoryProvider =
    StateNotifierProvider<OutfitHistoryNotifier, OutfitHistoryState>((ref) {
  return OutfitHistoryNotifier(ref.watch(outfitRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Favorites
// ---------------------------------------------------------------------------

class FavoritesState {
  final List<Outfit> outfits;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.outfits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FavoritesState copyWith({
    List<Outfit>? outfits,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      outfits: outfits ?? this.outfits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final OutfitRepository _repository;

  FavoritesNotifier(this._repository) : super(const FavoritesState()) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final outfits = await _repository.getFavorites();
      state = state.copyWith(outfits: outfits, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
      // Toggle locally — 204 no body from backend
      final newList = state.outfits.map((o) {
        return o.id == id ? o.copyWith(isFavorite: !o.isFavorite) : o;
      }).toList();
      final filtered = newList.where((o) => o.isFavorite).toList();
      state = state.copyWith(outfits: filtered);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(outfitRepositoryProvider));
});
