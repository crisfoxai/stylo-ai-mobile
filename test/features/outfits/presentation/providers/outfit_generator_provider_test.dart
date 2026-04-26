import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class FakeOutfitRepository implements OutfitRepository {
  Exception? errorToThrow;
  String? lastGenerateMood;
  String? lastGenerateEvent;

  void throwOnNextCall(Exception e) => errorToThrow = e;

  Outfit _makeOutfit({bool isFavorite = false, DateTime? wornAt}) {
    return Outfit(
      id: 'outfit-test',
      name: 'Test Outfit',
      garments: [
        const OutfitGarment(
          garmentId: 'g1',
          type: 'top',
          color: 'white',
          style: 'casual',
        ),
      ],
      isFavorite: isFavorite,
      wornAt: wornAt,
      createdAt: DateTime(2024),
    );
  }

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    lastGenerateMood = mood;
    lastGenerateEvent = event;
    return _makeOutfit();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
  }

  @override
  Future<void> logWorn(String id) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
  }

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async => [];

  @override
  Future<Outfit> getOutfit(String id) async => _makeOutfit();

  @override
  Future<List<Outfit>> getFavorites() async => [];

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async => [];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ProviderContainer makeContainer(FakeOutfitRepository repo) {
  return ProviderContainer(
    overrides: [outfitRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  late FakeOutfitRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeOutfitRepository();
    container = makeContainer(fakeRepo);
  });

  tearDown(() => container.dispose());

  // ── OutfitGeneratorStep enum ────────────────────────────────────────────────

  group('OutfitGeneratorStep enum', () {
    test('has five values', () {
      expect(OutfitGeneratorStep.values.length, 5);
    });

    test('contains expected values', () {
      expect(OutfitGeneratorStep.values, containsAll([
        OutfitGeneratorStep.idle,
        OutfitGeneratorStep.selecting,
        OutfitGeneratorStep.generating,
        OutfitGeneratorStep.result,
        OutfitGeneratorStep.error,
      ]));
    });
  });

  // ── OutfitGeneratorState ────────────────────────────────────────────────────

  group('OutfitGeneratorState', () {
    test('default constructor has idle step and null selections', () {
      const state = OutfitGeneratorState();
      expect(state.step, OutfitGeneratorStep.idle);
      expect(state.selectedMood, isNull);
      expect(state.selectedEvent, isNull);
      expect(state.generatedOutfit, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isFavoriting, isFalse);
      expect(state.isLoggingWorn, isFalse);
    });

    group('canGenerate', () {
      test('returns false when both mood and event are null', () {
        expect(const OutfitGeneratorState().canGenerate, isFalse);
      });

      test('returns false when only mood is set', () {
        const state = OutfitGeneratorState(selectedMood: 'happy');
        expect(state.canGenerate, isFalse);
      });

      test('returns false when only event is set', () {
        const state = OutfitGeneratorState(selectedEvent: 'work');
        expect(state.canGenerate, isFalse);
      });

      test('returns true when both mood and event are set', () {
        const state = OutfitGeneratorState(
          selectedMood: 'happy',
          selectedEvent: 'work',
        );
        expect(state.canGenerate, isTrue);
      });
    });

    group('copyWith', () {
      test('clearMood sets selectedMood to null', () {
        const state = OutfitGeneratorState(selectedMood: 'happy');
        final cleared = state.copyWith(clearMood: true);
        expect(cleared.selectedMood, isNull);
      });

      test('clearEvent sets selectedEvent to null', () {
        const state = OutfitGeneratorState(selectedEvent: 'work');
        final cleared = state.copyWith(clearEvent: true);
        expect(cleared.selectedEvent, isNull);
      });

      test('clearOutfit sets generatedOutfit to null', () {
        final outfit = Outfit(
          id: 'o1',
          name: 'n',
          garments: [],
          createdAt: DateTime(2024),
        );
        final state = OutfitGeneratorState(generatedOutfit: outfit);
        final cleared = state.copyWith(clearOutfit: true);
        expect(cleared.generatedOutfit, isNull);
      });

      test('clearError sets errorMessage to null', () {
        const state = OutfitGeneratorState(errorMessage: 'oops');
        final cleared = state.copyWith(clearError: true);
        expect(cleared.errorMessage, isNull);
      });
    });
  });

  // ── OutfitGeneratorNotifier initialization ──────────────────────────────────

  group('OutfitGeneratorNotifier initialization', () {
    test('starts with selecting step', () {
      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
    });
  });

  // ── setMood ─────────────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.setMood', () {
    test('sets mood when none was selected', () {
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      expect(container.read(outfitGeneratorProvider).selectedMood, 'happy');
    });

    test('toggles mood off when same value is set again', () {
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      expect(container.read(outfitGeneratorProvider).selectedMood, isNull);
    });

    test('replaces existing mood with new selection', () {
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      container.read(outfitGeneratorProvider.notifier).setMood('bold');
      expect(container.read(outfitGeneratorProvider).selectedMood, 'bold');
    });
  });

  // ── setEvent ────────────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.setEvent', () {
    test('sets event when none was selected', () {
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      expect(container.read(outfitGeneratorProvider).selectedEvent, 'work');
    });

    test('toggles event off when same value is set again', () {
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      expect(container.read(outfitGeneratorProvider).selectedEvent, isNull);
    });

    test('replaces existing event with new selection', () {
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      container.read(outfitGeneratorProvider.notifier).setEvent('date');
      expect(container.read(outfitGeneratorProvider).selectedEvent, 'date');
    });
  });

  // ── generateOutfit ──────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.generateOutfit', () {
    test('does nothing when canGenerate is false', () async {
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      expect(container.read(outfitGeneratorProvider).step,
          OutfitGeneratorStep.selecting);
    });

    test('transitions to result step with outfit on success', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('confident');
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.result);
      expect(state.generatedOutfit, isNotNull);
      expect(state.generatedOutfit!.id, 'outfit-test');
    });

    test('passes correct mood and event to repository', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      container.read(outfitGeneratorProvider.notifier).setEvent('casual');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();

      expect(fakeRepo.lastGenerateMood, 'happy');
      expect(fakeRepo.lastGenerateEvent, 'casual');
    });

    test('transitions to error step on failure', () async {
      fakeRepo.throwOnNextCall(Exception('AI service unavailable'));
      container.read(outfitGeneratorProvider.notifier).setMood('happy');
      container.read(outfitGeneratorProvider.notifier).setEvent('party');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.error);
      expect(state.errorMessage, contains('AI service unavailable'));
    });
  });

  // ── regenerateOutfit ────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.regenerateOutfit', () {
    test('resets to selecting step and clears outfit', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('bold');
      container.read(outfitGeneratorProvider.notifier).setEvent('party');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      expect(container.read(outfitGeneratorProvider).generatedOutfit, isNotNull);

      await container
          .read(outfitGeneratorProvider.notifier)
          .regenerateOutfit();

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
      expect(state.generatedOutfit, isNull);
    });
  });

  // ── favoriteOutfit ──────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.favoriteOutfit', () {
    test('does nothing when no outfit is generated', () async {
      await container.read(outfitGeneratorProvider.notifier).favoriteOutfit();
      expect(container.read(outfitGeneratorProvider).isFavoriting, isFalse);
    });

    test('updates outfit with favorite flag on success', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('relaxed');
      container.read(outfitGeneratorProvider.notifier).setEvent('weekend');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      await container.read(outfitGeneratorProvider.notifier).favoriteOutfit();

      final state = container.read(outfitGeneratorProvider);
      expect(state.isFavoriting, isFalse);
      expect(state.generatedOutfit!.isFavorite, isTrue);
    });

    test('sets errorMessage when toggleFavorite fails', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('calm');
      container.read(outfitGeneratorProvider.notifier).setEvent('home');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      fakeRepo.throwOnNextCall(Exception('Server error'));
      await container.read(outfitGeneratorProvider.notifier).favoriteOutfit();

      final state = container.read(outfitGeneratorProvider);
      expect(state.isFavoriting, isFalse);
      expect(state.errorMessage, contains('Server error'));
    });
  });

  // ── swapGarment ─────────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.swapGarment', () {
    test('does nothing when canGenerate is false', () async {
      await container
          .read(outfitGeneratorProvider.notifier)
          .swapGarment('g1');
      expect(container.read(outfitGeneratorProvider).step,
          OutfitGeneratorStep.selecting);
    });

    test('regenerates outfit on success', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('bold');
      container.read(outfitGeneratorProvider.notifier).setEvent('party');
      await container
          .read(outfitGeneratorProvider.notifier)
          .swapGarment('g1');

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.result);
      expect(state.generatedOutfit, isNotNull);
    });

    test('transitions to error on failure', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('bold');
      container.read(outfitGeneratorProvider.notifier).setEvent('party');
      fakeRepo.throwOnNextCall(Exception('Swap failed'));
      await container
          .read(outfitGeneratorProvider.notifier)
          .swapGarment('g1');

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.error);
      expect(state.errorMessage, contains('Swap failed'));
    });
  });

  // ── logAsWorn ──────────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.logAsWorn', () {
    test('does nothing when no outfit is generated', () async {
      await container.read(outfitGeneratorProvider.notifier).logAsWorn();
      expect(container.read(outfitGeneratorProvider).isLoggingWorn, isFalse);
    });

    test('shows success message on success', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('confident');
      container.read(outfitGeneratorProvider.notifier).setEvent('work');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      await container.read(outfitGeneratorProvider.notifier).logAsWorn();

      final state = container.read(outfitGeneratorProvider);
      expect(state.isLoggingWorn, isFalse);
      expect(state.successMessage, isNotNull);
    });

    test('sets errorMessage when logWorn fails', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('calm');
      container.read(outfitGeneratorProvider.notifier).setEvent('home');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();
      fakeRepo.throwOnNextCall(Exception('Log failed'));
      await container.read(outfitGeneratorProvider.notifier).logAsWorn();

      final state = container.read(outfitGeneratorProvider);
      expect(state.isLoggingWorn, isFalse);
      expect(state.errorMessage, contains('Log failed'));
    });
  });

  // ── reset ───────────────────────────────────────────────────────────────────

  group('OutfitGeneratorNotifier.reset', () {
    test('resets state to selecting step with null selections', () async {
      container.read(outfitGeneratorProvider.notifier).setMood('bold');
      container.read(outfitGeneratorProvider.notifier).setEvent('party');
      await container.read(outfitGeneratorProvider.notifier).generateOutfit();

      container.read(outfitGeneratorProvider.notifier).reset();

      final state = container.read(outfitGeneratorProvider);
      expect(state.step, OutfitGeneratorStep.selecting);
      expect(state.selectedMood, isNull);
      expect(state.selectedEvent, isNull);
      expect(state.generatedOutfit, isNull);
    });
  });
}
