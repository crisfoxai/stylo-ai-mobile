import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/outfit_remote_datasource.dart';
import '../../data/repositories/outfit_repository_impl.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/repositories/outfit_repository.dart';

final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  return OutfitRepositoryImpl(
    OutfitRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

enum OutfitGeneratorStep { idle, selecting, generating, result, error }

class OutfitGeneratorState {
  final OutfitGeneratorStep step;
  final String? selectedMood;
  final String? selectedEvent;
  final Outfit? generatedOutfit;
  final String? errorMessage;
  final bool isFavoriting;
  final bool isLoggingWorn;

  const OutfitGeneratorState({
    this.step = OutfitGeneratorStep.idle,
    this.selectedMood,
    this.selectedEvent,
    this.generatedOutfit,
    this.errorMessage,
    this.isFavoriting = false,
    this.isLoggingWorn = false,
  });

  OutfitGeneratorState copyWith({
    OutfitGeneratorStep? step,
    String? selectedMood,
    String? selectedEvent,
    Outfit? generatedOutfit,
    String? errorMessage,
    bool? isFavoriting,
    bool? isLoggingWorn,
    bool clearMood = false,
    bool clearEvent = false,
    bool clearOutfit = false,
    bool clearError = false,
  }) {
    return OutfitGeneratorState(
      step: step ?? this.step,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      selectedEvent: clearEvent ? null : (selectedEvent ?? this.selectedEvent),
      generatedOutfit:
          clearOutfit ? null : (generatedOutfit ?? this.generatedOutfit),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFavoriting: isFavoriting ?? this.isFavoriting,
      isLoggingWorn: isLoggingWorn ?? this.isLoggingWorn,
    );
  }

  bool get canGenerate =>
      selectedMood != null && selectedEvent != null;
}

class OutfitGeneratorNotifier extends StateNotifier<OutfitGeneratorState> {
  final OutfitRepository _repository;

  OutfitGeneratorNotifier(this._repository)
      : super(const OutfitGeneratorState(step: OutfitGeneratorStep.selecting));

  void setMood(String mood) {
    final newMood = state.selectedMood == mood ? null : mood;
    state = state.copyWith(
      selectedMood: newMood,
      clearMood: newMood == null,
      clearError: true,
    );
  }

  void setEvent(String event) {
    final newEvent = state.selectedEvent == event ? null : event;
    state = state.copyWith(
      selectedEvent: newEvent,
      clearEvent: newEvent == null,
      clearError: true,
    );
  }

  Future<void> generateOutfit() async {
    if (!state.canGenerate) return;
    state = state.copyWith(
      step: OutfitGeneratorStep.generating,
      clearError: true,
    );
    try {
      final outfit = await _repository.generateOutfit(
        mood: state.selectedMood!,
        event: state.selectedEvent!,
      );
      state = state.copyWith(
        step: OutfitGeneratorStep.result,
        generatedOutfit: outfit,
      );
    } catch (e) {
      state = state.copyWith(
        step: OutfitGeneratorStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> regenerateOutfit() async {
    state = state.copyWith(
      step: OutfitGeneratorStep.selecting,
      clearOutfit: true,
      clearError: true,
    );
  }

  Future<void> swapGarment(String garmentId) async {
    // Trigger re-generation with the same mood/event; the backend
    // can handle garment exclusions via an optional parameter.
    if (!state.canGenerate) return;
    state = state.copyWith(
      step: OutfitGeneratorStep.generating,
      clearError: true,
    );
    try {
      final outfit = await _repository.generateOutfit(
        mood: state.selectedMood!,
        event: state.selectedEvent!,
      );
      state = state.copyWith(
        step: OutfitGeneratorStep.result,
        generatedOutfit: outfit,
      );
    } catch (e) {
      state = state.copyWith(
        step: OutfitGeneratorStep.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> favoriteOutfit() async {
    final outfit = state.generatedOutfit;
    if (outfit == null || state.isFavoriting) return;
    state = state.copyWith(isFavoriting: true);
    try {
      final updated = await _repository.toggleFavorite(outfit.id);
      state = state.copyWith(
        generatedOutfit: updated,
        isFavoriting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isFavoriting: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logAsWorn() async {
    final outfit = state.generatedOutfit;
    if (outfit == null || state.isLoggingWorn) return;
    state = state.copyWith(isLoggingWorn: true);
    try {
      final updated = await _repository.logWorn(outfit.id);
      state = state.copyWith(
        generatedOutfit: updated,
        isLoggingWorn: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoggingWorn: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const OutfitGeneratorState(step: OutfitGeneratorStep.selecting);
  }
}

final outfitGeneratorProvider =
    StateNotifierProvider<OutfitGeneratorNotifier, OutfitGeneratorState>((ref) {
  return OutfitGeneratorNotifier(ref.watch(outfitRepositoryProvider));
});
