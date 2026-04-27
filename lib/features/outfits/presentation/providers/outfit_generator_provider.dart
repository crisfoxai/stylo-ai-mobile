import '../../../../core/errors/app_exception.dart';
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
  final String? successMessage;
  final bool isFavoriting;
  final bool isLoggingWorn;

  const OutfitGeneratorState({
    this.step = OutfitGeneratorStep.idle,
    this.selectedMood,
    this.selectedEvent,
    this.generatedOutfit,
    this.errorMessage,
    this.successMessage,
    this.isFavoriting = false,
    this.isLoggingWorn = false,
  });

  OutfitGeneratorState copyWith({
    OutfitGeneratorStep? step,
    String? selectedMood,
    String? selectedEvent,
    Outfit? generatedOutfit,
    String? errorMessage,
    String? successMessage,
    bool? isFavoriting,
    bool? isLoggingWorn,
    bool clearMood = false,
    bool clearEvent = false,
    bool clearOutfit = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return OutfitGeneratorState(
      step: step ?? this.step,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      selectedEvent: clearEvent ? null : (selectedEvent ?? this.selectedEvent),
      generatedOutfit:
          clearOutfit ? null : (generatedOutfit ?? this.generatedOutfit),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
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
        errorMessage: AppException.extractMessage(e),
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
    if (!state.canGenerate) return;
    state = state.copyWith(
      step: OutfitGeneratorStep.generating,
      clearError: true,
    );
    try {
      final outfit = await _repository.generateOutfit(
        mood: state.selectedMood!,
        event: state.selectedEvent!,
        excludeIds: [garmentId],
      );
      state = state.copyWith(
        step: OutfitGeneratorStep.result,
        generatedOutfit: outfit,
      );
    } catch (e) {
      state = state.copyWith(
        step: OutfitGeneratorStep.error,
        errorMessage: AppException.extractMessage(e),
      );
    }
  }

  Future<void> favoriteOutfit() async {
    final outfit = state.generatedOutfit;
    if (outfit == null || state.isFavoriting) return;
    final wasFavorite = outfit.isFavorite;
    state = state.copyWith(isFavoriting: true, clearSuccess: true);
    try {
      await _repository.toggleFavorite(outfit.id, wasFavorite: wasFavorite);
      state = state.copyWith(
        generatedOutfit: state.generatedOutfit?.copyWith(isFavorite: !wasFavorite),
        isFavoriting: false,
        successMessage: wasFavorite ? 'Eliminado de favoritos' : 'Guardado en favoritos',
      );
    } catch (e) {
      state = state.copyWith(
        isFavoriting: false,
        errorMessage: AppException.extractMessage(e),
      );
    }
  }

  Future<void> logAsWorn() async {
    final outfit = state.generatedOutfit;
    if (outfit == null || state.isLoggingWorn) return;
    state = state.copyWith(isLoggingWorn: true, clearSuccess: true);
    try {
      await _repository.logWorn(outfit.id);
      state = state.copyWith(
        isLoggingWorn: false,
        successMessage: 'Registrado para hoy',
      );
    } catch (e) {
      state = state.copyWith(
        isLoggingWorn: false,
        errorMessage: AppException.extractMessage(e),
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
