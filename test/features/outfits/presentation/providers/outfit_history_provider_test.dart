import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_history_provider.dart';

class FakeOutfitRepository implements OutfitRepository {
  List<Outfit> historyOutfits;
  List<Outfit> favoriteOutfits;
  Exception? errorToThrow;

  FakeOutfitRepository({
    List<Outfit>? history,
    List<Outfit>? favorites,
  })  : historyOutfits = history ?? [],
        favoriteOutfits = favorites ?? [];

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return historyOutfits;
  }

  @override
  Future<List<Outfit>> getFavorites() async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return favoriteOutfits;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    // Toggle isFavorite (no-op in fake)
  }

  Outfit _makeOutfit({String id = 'o-1', bool isFavorite = false}) => Outfit(
        id: id,
        name: 'Outfit $id',
        garments: const [
          OutfitGarment(garmentId: 'g1', type: 'top', color: 'white', style: 'casual'),
        ],
        isFavorite: isFavorite,
        createdAt: DateTime(2024),
      );

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) async =>
      _makeOutfit();
  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async => [];
  @override
  Future<Outfit> getOutfit(String id) async => _makeOutfit(id: id);
  @override
  Future<void> logWorn(String id) async {}
}

void main() {
  group('OutfitHistoryState', () {
    test('default has sensible defaults', () {
      const state = OutfitHistoryState();
      expect(state.outfits, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.currentPage, 1);
      expect(state.hasMore, isTrue);
    });

    test('copyWith overrides fields', () {
      const state = OutfitHistoryState();
      final updated = state.copyWith(isLoading: true, currentPage: 2);
      expect(updated.isLoading, isTrue);
      expect(updated.currentPage, 2);
    });

    test('clearError removes errorMessage', () {
      const state = OutfitHistoryState(errorMessage: 'oops');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('OutfitHistoryNotifier', () {
    test('loads on initialization', () async {
      final repo = FakeOutfitRepository(
        history: [
          Outfit(id: 'o1', name: 'O1', garments: const [], createdAt: DateTime(2024)),
        ],
      );
      final container = ProviderContainer(
        overrides: [outfitRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      // Trigger the provider and wait for async load
      container.read(outfitHistoryProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(outfitHistoryProvider);
      expect(state.outfits.length, 1);
      expect(state.isLoading, isFalse);
    });

    test('sets error on load failure', () async {
      final repo = FakeOutfitRepository();
      repo.errorToThrow = Exception('Failed to load');
      final container = ProviderContainer(
        overrides: [outfitRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      container.read(outfitHistoryProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(outfitHistoryProvider);
      expect(state.errorMessage, contains('Failed to load'));
    });
  });

  group('FavoritesState', () {
    test('default has sensible defaults', () {
      const state = FavoritesState();
      expect(state.outfits, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith with clearError', () {
      const state = FavoritesState(errorMessage: 'err');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });

  group('FavoritesNotifier', () {
    test('loads favorites on initialization', () async {
      final repo = FakeOutfitRepository(
        favorites: [
          Outfit(
            id: 'f1',
            name: 'Fav1',
            garments: const [],
            isFavorite: true,
            createdAt: DateTime(2024),
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [outfitRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      container.read(favoritesProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(favoritesProvider);
      expect(state.outfits.length, 1);
    });
  });
}
