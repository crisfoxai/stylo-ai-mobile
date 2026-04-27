import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/outfit.dart';
import '../../data/repositories/outfit_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/outfit_remote_datasource.dart';

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

final outfitRepositoryProvider = Provider((ref) {
  return OutfitRepositoryImpl(
    OutfitRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final outfitsListProvider =
    FutureProvider.family<OutfitsPage, OutfitsListFilter>((ref, filter) async {
  return ref.read(outfitRepositoryProvider).getAllPaged(filter);
});
