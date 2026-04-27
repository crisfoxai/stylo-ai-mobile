import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import 'outfit_generator_provider.dart' show outfitRepositoryProvider;

part 'outfits_list_provider.freezed.dart';

@freezed
class OutfitsListFilter with _$OutfitsListFilter {
  const factory OutfitsListFilter({
    @Default(1) int page,
    @Default('newest') String sort,
    String? occasion,
    @Default(false) bool onlyFavorites,
    @Default(false) bool onlyWithLookPhoto,
  }) = _OutfitsListFilter;
}

final outfitsListFilterProvider =
    StateProvider<OutfitsListFilter>((_) => const OutfitsListFilter());

final outfitsListProvider =
    FutureProvider.family<OutfitsPage, OutfitsListFilter>((ref, filter) async {
  return ref.read(outfitRepositoryProvider).getAllPaged(filter);
});
