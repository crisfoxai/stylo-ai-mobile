import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';
import 'package:stylo_ai/features/outfits/domain/entities/wardrobe_count.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/detection_result.dart';
import 'package:stylo_ai/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:stylo_ai/features/wardrobe/presentation/providers/wardrobe_provider.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class FakeWardrobeRepository implements WardrobeRepository {
  List<Garment> garments;
  bool deleteWasCalled = false;
  String? deletedId;
  String? searchQuery;
  Exception? errorToThrow;

  FakeWardrobeRepository({List<Garment>? garments})
      : garments = garments ?? [];

  void throwOnNextCall(Exception e) => errorToThrow = e;

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    final filtered = filters != null && filters['type'] != null
        ? garments.where((g) => g.type == filters['type']).toList()
        : garments;
    return PaginatedGarments(
      items: filtered,
      total: filtered.length,
      page: page,
      limit: limit,
      hasMore: false,
    );
  }

  @override
  Future<Garment> getGarment(String id) async {
    return garments.firstWhere((g) => g.id == id);
  }

  @override
  Future<void> deleteGarment(String id) async {
    deleteWasCalled = true;
    deletedId = id;
    garments.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<Garment>> searchGarments(String query) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    searchQuery = query;
    return garments
        .where((g) =>
            g.name.toLowerCase().contains(query.toLowerCase()) ||
            g.type.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<ScanJobResult> scanGarment(String imagePath) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return const ScanJobResult(jobId: 'job-1', status: 'processing');
  }

  @override
  Future<ScanJobStatus> checkScanJob(String jobId) async {
    return ScanJobStatus(jobId: jobId, status: 'processing');
  }

  @override
  Future<Garment> updateGarment(String id, Map<String, dynamic> data) async {
    return garments.firstWhere((g) => g.id == id);
  }

  @override
  Future<WardrobeCount> getCount() async =>
      const WardrobeCount(count: 0, threshold: 5, state: 'empty');

  @override
  Future<DetectionResult> detectFromPhoto(String filePath) async =>
      throw UnimplementedError();

  @override
  Future<List<String>> confirmDetection(
          String photoKey, List<DetectedGarmentEdit> garments) async =>
      [];
}

// ── Fixtures ──────────────────────────────────────────────────────────────────

Garment makeGarment({
  String id = 'g1',
  String name = 'T-Shirt',
  String type = 'top',
  List<String> tags = const [],
}) {
  final now = DateTime(2024);
  return Garment(
    id: id,
    name: name,
    imageUrl: 'https://example.com/$id.jpg',
    type: type,
    userId: 'user-1',
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}

ProviderContainer makeContainer(FakeWardrobeRepository repo) {
  return ProviderContainer(
    overrides: [wardrobeRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  // ── ScanStep enum ───────────────────────────────────────────────────────────

  group('ScanStep enum', () {
    test('has six values', () {
      expect(ScanStep.values.length, 6);
    });

    test('contains expected values', () {
      expect(ScanStep.values, containsAll([
        ScanStep.idle,
        ScanStep.capturing,
        ScanStep.uploading,
        ScanStep.processing,
        ScanStep.done,
        ScanStep.error,
      ]));
    });
  });

  // ── WardrobeState ───────────────────────────────────────────────────────────

  group('WardrobeState', () {
    test('default constructor has sensible defaults', () {
      const state = WardrobeState();
      expect(state.garments, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.currentPage, 1);
      expect(state.hasMore, isTrue);
      expect(state.total, 0);
      expect(state.activeFilter, isNull);
      expect(state.searchQuery, '');
    });

    test('copyWith overrides specified fields', () {
      const state = WardrobeState();
      final updated = state.copyWith(isLoading: true, total: 5);
      expect(updated.isLoading, isTrue);
      expect(updated.total, 5);
      expect(updated.garments, isEmpty);
    });

    test('clearError removes errorMessage', () {
      const state = WardrobeState(errorMessage: 'oops');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('clearFilter removes activeFilter', () {
      const state = WardrobeState(activeFilter: 'top');
      final cleared = state.copyWith(clearFilter: true);
      expect(cleared.activeFilter, isNull);
    });
  });

  // ── WardrobeNotifier.loadGarments ───────────────────────────────────────────

  group('WardrobeNotifier.loadGarments', () {
    test('loads garments into state on success', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1'),
        makeGarment(id: 'g2'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();

      final state = container.read(wardrobeNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.garments.length, 2);
      expect(state.errorMessage, isNull);
    });

    test('sets error state on failure', () async {
      final repo = FakeWardrobeRepository();
      repo.throwOnNextCall(Exception('Network error'));
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();

      final state = container.read(wardrobeNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Network error'));
    });

    test('refresh clears existing garments before loading', () async {
      final repo = FakeWardrobeRepository(garments: [makeGarment(id: 'g1')]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      expect(container.read(wardrobeNotifierProvider).garments.length, 1);

      repo.garments = [makeGarment(id: 'g2'), makeGarment(id: 'g3')];
      await container
          .read(wardrobeNotifierProvider.notifier)
          .loadGarments(refresh: true);

      final state = container.read(wardrobeNotifierProvider);
      expect(state.garments.length, 2);
      expect(state.garments.first.id, 'g2');
    });

    test('does not reload when already loading', () async {
      final repo = FakeWardrobeRepository();
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      // Manually set loading state
      container.read(wardrobeNotifierProvider.notifier).state =
          const WardrobeState(isLoading: true);

      // This call should be a no-op
      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      // State remains loading — we did not flip isLoading to false
      expect(container.read(wardrobeNotifierProvider).isLoading, isTrue);
    });
  });

  // ── WardrobeNotifier.addGarment ─────────────────────────────────────────────

  group('WardrobeNotifier.addGarment', () {
    test('prepends the garment to the list and increments total', () async {
      final repo = FakeWardrobeRepository(garments: [makeGarment(id: 'g1')]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      final before = container.read(wardrobeNotifierProvider);
      expect(before.total, 1);

      container
          .read(wardrobeNotifierProvider.notifier)
          .addGarment(makeGarment(id: 'g-new', name: 'New Dress'));

      final after = container.read(wardrobeNotifierProvider);
      expect(after.garments.length, 2);
      expect(after.garments.first.id, 'g-new');
      expect(after.total, 2);
    });
  });

  // ── WardrobeNotifier.deleteGarment ──────────────────────────────────────────

  group('WardrobeNotifier.deleteGarment', () {
    test('removes garment from state and decrements total', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1'),
        makeGarment(id: 'g2'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      await container
          .read(wardrobeNotifierProvider.notifier)
          .deleteGarment('g1');

      final state = container.read(wardrobeNotifierProvider);
      expect(state.garments.length, 1);
      expect(state.garments.first.id, 'g2');
      expect(state.total, 1);
      expect(repo.deleteWasCalled, isTrue);
      expect(repo.deletedId, 'g1');
    });
  });

  // ── WardrobeNotifier.setFilter ──────────────────────────────────────────────

  group('WardrobeNotifier.setFilter', () {
    test('applies filter and reloads garments', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', type: 'top'),
        makeGarment(id: 'g2', type: 'bottom'),
        makeGarment(id: 'g3', type: 'top'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .setFilter('top');

      final state = container.read(wardrobeNotifierProvider);
      expect(state.activeFilter, 'top');
      expect(state.garments.every((g) => g.type == 'top'), isTrue);
    });

    test('clears filter when null is passed', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', type: 'top'),
        makeGarment(id: 'g2', type: 'bottom'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .setFilter('top');
      await container
          .read(wardrobeNotifierProvider.notifier)
          .setFilter(null);

      final state = container.read(wardrobeNotifierProvider);
      expect(state.activeFilter, isNull);
      expect(state.garments.length, 2);
    });

    test('does nothing when same filter is set again', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', type: 'top'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .setFilter('top');
      final stateAfterFirst = container.read(wardrobeNotifierProvider);

      // Calling setFilter with same value should be no-op
      await container
          .read(wardrobeNotifierProvider.notifier)
          .setFilter('top');
      final stateAfterSecond = container.read(wardrobeNotifierProvider);
      expect(stateAfterSecond.garments.length,
          stateAfterFirst.garments.length);
    });
  });

  // ── WardrobeNotifier.search ─────────────────────────────────────────────────

  group('WardrobeNotifier.search', () {
    test('searches garments and updates state with results', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', name: 'Blue Jeans', type: 'bottom'),
        makeGarment(id: 'g2', name: 'White Shirt', type: 'top'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .search('jeans');

      final state = container.read(wardrobeNotifierProvider);
      expect(state.garments.length, 1);
      expect(state.garments.first.id, 'g1');
      expect(state.searchQuery, 'jeans');
      expect(state.hasMore, isFalse);
    });

    test('reloads all garments when query is cleared', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', name: 'Blue Jeans', type: 'bottom'),
        makeGarment(id: 'g2', name: 'White Shirt', type: 'top'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .search('jeans');
      await container
          .read(wardrobeNotifierProvider.notifier)
          .search('');

      final state = container.read(wardrobeNotifierProvider);
      expect(state.garments.length, 2);
      expect(state.searchQuery, '');
    });

    test('sets error state when search fails', () async {
      final repo = FakeWardrobeRepository();
      repo.throwOnNextCall(Exception('Search service unavailable'));
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(wardrobeNotifierProvider.notifier)
          .search('anything');

      final state = container.read(wardrobeNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Search service unavailable'));
    });
  });

  // ── WardrobeNotifier.loadMore ────────────────────────────────────────────────

  group('WardrobeNotifier.loadMore', () {
    test('appends garments and increments page on success', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1'),
        makeGarment(id: 'g2'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      // Simulate having more pages
      container.read(wardrobeNotifierProvider.notifier).state =
          container.read(wardrobeNotifierProvider).copyWith(hasMore: true);

      repo.garments = [makeGarment(id: 'g3')];
      await container.read(wardrobeNotifierProvider.notifier).loadMore();

      final state = container.read(wardrobeNotifierProvider);
      expect(state.garments.length, 3);
      expect(state.currentPage, 2);
      expect(state.isLoadingMore, isFalse);
    });

    test('does nothing when hasMore is false', () async {
      final repo = FakeWardrobeRepository(garments: [makeGarment(id: 'g1')]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      // hasMore defaults to false from our fake
      await container.read(wardrobeNotifierProvider.notifier).loadMore();
      expect(container.read(wardrobeNotifierProvider).garments.length, 1);
    });

    test('does nothing when already loading more', () async {
      final repo = FakeWardrobeRepository(garments: [makeGarment(id: 'g1')]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      container.read(wardrobeNotifierProvider.notifier).state =
          const WardrobeState(isLoadingMore: true, hasMore: true);
      await container.read(wardrobeNotifierProvider.notifier).loadMore();
      expect(container.read(wardrobeNotifierProvider).isLoadingMore, isTrue);
    });

    test('sets error state on failure', () async {
      final repo = FakeWardrobeRepository(garments: [makeGarment(id: 'g1')]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      container.read(wardrobeNotifierProvider.notifier).state =
          container.read(wardrobeNotifierProvider).copyWith(hasMore: true);

      repo.throwOnNextCall(Exception('Timeout'));
      await container.read(wardrobeNotifierProvider.notifier).loadMore();

      final state = container.read(wardrobeNotifierProvider);
      expect(state.isLoadingMore, isFalse);
      expect(state.errorMessage, contains('Timeout'));
    });
  });

  // ── ScanState ──────────────────────────────────────────────────────────────

  group('ScanState', () {
    test('default has idle step and null fields', () {
      const state = ScanState();
      expect(state.step, ScanStep.idle);
      expect(state.imagePath, isNull);
      expect(state.jobId, isNull);
      expect(state.result, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith overrides specified fields', () {
      const state = ScanState();
      final updated = state.copyWith(
        step: ScanStep.uploading,
        imagePath: '/test.jpg',
      );
      expect(updated.step, ScanStep.uploading);
      expect(updated.imagePath, '/test.jpg');
    });
  });

  // ── GarmentScanNotifier ────────────────────────────────────────────────────

  group('GarmentScanNotifier', () {
    test('setImagePath sets capturing step with path', () {
      final repo = FakeWardrobeRepository();
      final notifier = GarmentScanNotifier(repo);
      addTearDown(notifier.dispose);

      notifier.setImagePath('/photo.jpg');
      expect(notifier.debugState.step, ScanStep.capturing);
      expect(notifier.debugState.imagePath, '/photo.jpg');
    });

    test('reset returns to idle state', () {
      final repo = FakeWardrobeRepository();
      final notifier = GarmentScanNotifier(repo);
      addTearDown(notifier.dispose);

      notifier.setImagePath('/photo.jpg');
      notifier.reset();
      expect(notifier.debugState.step, ScanStep.idle);
      expect(notifier.debugState.imagePath, isNull);
    });

    test('startScan transitions to processing on success', () async {
      final repo = FakeWardrobeRepository();
      final notifier = GarmentScanNotifier(repo);
      addTearDown(notifier.dispose);

      await notifier.startScan('/photo.jpg');
      expect(notifier.debugState.step, ScanStep.processing);
      expect(notifier.debugState.jobId, 'job-1');

      notifier.reset(); // clean up timer
    });

    test('startScan transitions to error on failure', () async {
      final repo = FakeWardrobeRepository();
      repo.throwOnNextCall(Exception('Upload failed'));
      final notifier = GarmentScanNotifier(repo);
      addTearDown(notifier.dispose);

      await notifier.startScan('/photo.jpg');
      expect(notifier.debugState.step, ScanStep.error);
      expect(notifier.debugState.errorMessage, contains('Upload failed'));
    });
  });

  // ── filteredWardrobeProvider ─────────────────────────────────────────────────

  group('filteredWardrobeProvider', () {
    test('returns all garments when searchQuery is empty', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', name: 'Shirt'),
        makeGarment(id: 'g2', name: 'Pants'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      final filtered = container.read(filteredWardrobeProvider);
      expect(filtered.length, 2);
    });

    test('filters garments locally by name when searchQuery is set', () async {
      final repo = FakeWardrobeRepository(garments: [
        makeGarment(id: 'g1', name: 'Blue Shirt', type: 'top'),
        makeGarment(id: 'g2', name: 'Red Dress', type: 'dress'),
      ]);
      final container = makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(wardrobeNotifierProvider.notifier).loadGarments();
      // Manually set search query without calling search() to test local filter
      container.read(wardrobeNotifierProvider.notifier).state =
          container.read(wardrobeNotifierProvider).copyWith(searchQuery: 'blue');

      final filtered = container.read(filteredWardrobeProvider);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'g1');
    });
  });
}
