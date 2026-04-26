import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';

class _FakeOutfitRepository implements OutfitRepository {
  bool shouldFail = false;
  int generateCount = 0;

  final _outfit = Outfit(
    id: 'o1',
    name: 'Test Outfit',
    garments: const [
      OutfitGarment(garmentId: 'g1', type: 'top', color: 'white', style: 'casual'),
      OutfitGarment(garmentId: 'g2', type: 'bottom', color: 'blue', style: 'casual'),
    ],
    mood: 'relajado',
    event: 'trabajo',
    isFavorite: false,
    createdAt: DateTime(2026, 3, 31),
  );

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) async {
    generateCount++;
    if (shouldFail) throw Exception('Generation failed');
    return _outfit;
  }

  @override
  Future<void> toggleFavorite(String id) async {
    if (shouldFail) throw Exception('Favorite failed');
  }

  @override
  Future<void> logWorn(String id) async {
    if (shouldFail) throw Exception('Log failed');
  }

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async => [_outfit];

  @override
  Future<List<Outfit>> getFavorites() async => [_outfit];

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async => [_outfit];

  @override
  Future<Outfit> getOutfit(String id) async => _outfit;
}

void main() {
  late ProviderContainer container;
  late _FakeOutfitRepository repo;

  setUp(() {
    repo = _FakeOutfitRepository();
    container = ProviderContainer(
      overrides: [
        outfitRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('OutfitGeneratorNotifier', () {
    test('initial state is selecting', () {
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
    });

    test('setMood toggles mood selection', () {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      expect(container.read(outfitGeneratorProvider).selectedMood, 'relajado');

      // Toggle same mood deselects
      notifier.setMood('relajado');
      expect(container.read(outfitGeneratorProvider).selectedMood, isNull);
    });

    test('setEvent toggles event selection', () {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setEvent('trabajo');
      expect(container.read(outfitGeneratorProvider).selectedEvent, 'trabajo');

      notifier.setEvent('trabajo');
      expect(container.read(outfitGeneratorProvider).selectedEvent, isNull);
    });

    test('canGenerate is false without both mood and event', () {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      expect(container.read(outfitGeneratorProvider).canGenerate, isFalse);

      notifier.setMood('relajado');
      expect(container.read(outfitGeneratorProvider).canGenerate, isFalse);

      notifier.setEvent('trabajo');
      expect(container.read(outfitGeneratorProvider).canGenerate, isTrue);
    });

    test('generateOutfit does nothing when canGenerate is false', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      await notifier.generateOutfit();
      expect(repo.generateCount, 0);
    });

    test('generateOutfit succeeds', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.result);
      expect(state.generatedOutfit, isNotNull);
    });

    test('generateOutfit handles error', () async {
      repo.shouldFail = true;
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.error);
      expect(state.errorMessage, isNotNull);
    });

    test('regenerateOutfit resets to selecting', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      await notifier.regenerateOutfit();
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
      expect(state.generatedOutfit, isNull);
    });

    test('swapGarment regenerates with same params', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      await notifier.swapGarment('g1');
      expect(repo.generateCount, 2);
      expect(container.read(outfitGeneratorProvider).step, OutfitGeneratorStep.result);
    });

    test('swapGarment handles error', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      repo.shouldFail = true;
      await notifier.swapGarment('g1');
      expect(container.read(outfitGeneratorProvider).step, OutfitGeneratorStep.error);
    });

    test('favoriteOutfit updates outfit', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      await notifier.favoriteOutfit();
      final state = container.read(outfitGeneratorProvider);
      expect(state.generatedOutfit!.isFavorite, isTrue);
      expect(state.isFavoriting, isFalse);
    });

    test('favoriteOutfit handles error', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      repo.shouldFail = true;
      await notifier.favoriteOutfit();
      expect(container.read(outfitGeneratorProvider).errorMessage, isNotNull);
    });

    test('favoriteOutfit does nothing without outfit', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      await notifier.favoriteOutfit();
      // Should not throw
    });

    test('logAsWorn updates outfit', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      await notifier.logAsWorn();
      final state = container.read(outfitGeneratorProvider);
      expect(state.successMessage, isNotNull);
      expect(state.isLoggingWorn, isFalse);
    });

    test('logAsWorn handles error', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      repo.shouldFail = true;
      await notifier.logAsWorn();
      expect(container.read(outfitGeneratorProvider).errorMessage, isNotNull);
    });

    test('reset returns to initial selecting state', () async {
      final notifier = container.read(outfitGeneratorProvider.notifier);
      notifier.setMood('relajado');
      notifier.setEvent('trabajo');
      await notifier.generateOutfit();
      notifier.reset();
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
      expect(state.selectedMood, isNull);
      expect(state.selectedEvent, isNull);
      expect(state.generatedOutfit, isNull);
    });
  });

  group('OutfitGeneratorState.copyWith', () {
    test('clearMood sets mood to null', () {
      const state = OutfitGeneratorState(selectedMood: 'happy');
      final copy = state.copyWith(clearMood: true);
      expect(copy.selectedMood, isNull);
    });

    test('clearEvent sets event to null', () {
      const state = OutfitGeneratorState(selectedEvent: 'party');
      final copy = state.copyWith(clearEvent: true);
      expect(copy.selectedEvent, isNull);
    });

    test('clearOutfit sets outfit to null', () {
      final state = OutfitGeneratorState(
        generatedOutfit: Outfit(
          id: '1',
          name: 'Test',
          garments: const [],
          createdAt: DateTime(2026),
        ),
      );
      final copy = state.copyWith(clearOutfit: true);
      expect(copy.generatedOutfit, isNull);
    });

    test('clearError sets error to null', () {
      const state = OutfitGeneratorState(errorMessage: 'oops');
      final copy = state.copyWith(clearError: true);
      expect(copy.errorMessage, isNull);
    });
  });
}
