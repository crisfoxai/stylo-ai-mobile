import '../../../../core/services/calendar_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/share_card_result.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../../presentation/providers/outfits_list_provider.dart';
import '../datasources/outfit_remote_datasource.dart';

class OutfitRepositoryImpl implements OutfitRepository {
  final OutfitRemoteDataSource _remoteDataSource;

  OutfitRepositoryImpl(this._remoteDataSource);

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
    WeatherContext? weatherContext,
    List<CalendarEventContext>? calendarEvents,
  }) =>
      _remoteDataSource.generateOutfit(
        mood: mood,
        event: event,
        excludeIds: excludeIds,
        weatherContext: weatherContext,
        calendarEvents: calendarEvents,
      );

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) =>
      _remoteDataSource.getOutfits(page: page, limit: limit);

  @override
  Future<OutfitsPage> getAllPaged(OutfitsListFilter filter) =>
      _remoteDataSource.getAllPaged(filter);

  @override
  Future<Outfit> getOutfit(String id) => _remoteDataSource.getOutfit(id);

  @override
  Future<void> toggleFavorite(String id, {bool wasFavorite = false}) =>
      _remoteDataSource.toggleFavorite(id, wasFavorite: wasFavorite);

  @override
  Future<void> logWorn(String id) => _remoteDataSource.logWorn(id);

  @override
  Future<List<Outfit>> getFavorites() => _remoteDataSource.getFavorites();

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) =>
      _remoteDataSource.getHistory(page: page, limit: limit);

  @override
  Future<ShareCardResult> generateShareCard(String outfitId) =>
      _remoteDataSource.generateShareCard(outfitId);

  @override
  Future<Map<String, dynamic>> uploadLookPhoto(
          String outfitId, String filePath) =>
      _remoteDataSource.uploadLookPhoto(outfitId, filePath);

  @override
  Future<void> deleteLookPhoto(String outfitId) =>
      _remoteDataSource.deleteLookPhoto(outfitId);
}
