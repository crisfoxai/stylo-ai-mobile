import '../entities/outfit.dart';
import '../entities/share_card_result.dart';
import '../../../../core/services/calendar_service.dart';
import '../../../../core/services/weather_service.dart';
import '../../presentation/providers/outfits_list_provider.dart';

abstract class OutfitRepository {
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
    WeatherContext? weatherContext,
    List<CalendarEventContext>? calendarEvents,
  });
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20});
  Future<OutfitsPage> getAllPaged(OutfitsListFilter filter);
  Future<Outfit> getOutfit(String id);
  Future<void> toggleFavorite(String id, {bool wasFavorite = false});
  Future<void> logWorn(String id);
  Future<List<Outfit>> getFavorites();
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20});
  Future<ShareCardResult> generateShareCard(String outfitId);
  Future<Map<String, dynamic>> uploadLookPhoto(String outfitId, String filePath);
  Future<void> deleteLookPhoto(String outfitId);
}
