import '../../domain/entities/outfit.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../datasources/outfit_remote_datasource.dart';

class OutfitRepositoryImpl implements OutfitRepository {
  final OutfitRemoteDataSource _remoteDataSource;

  OutfitRepositoryImpl(this._remoteDataSource);

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) =>
      _remoteDataSource.generateOutfit(mood: mood, event: event, excludeIds: excludeIds);

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) =>
      _remoteDataSource.getOutfits(page: page, limit: limit);

  @override
  Future<Outfit> getOutfit(String id) => _remoteDataSource.getOutfit(id);

  @override
  Future<void> toggleFavorite(String id) => _remoteDataSource.toggleFavorite(id);

  @override
  Future<void> logWorn(String id) => _remoteDataSource.logWorn(id);

  @override
  Future<List<Outfit>> getFavorites() => _remoteDataSource.getFavorites();

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) =>
      _remoteDataSource.getHistory(page: page, limit: limit);
}
