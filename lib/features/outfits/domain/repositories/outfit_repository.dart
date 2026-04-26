import '../entities/outfit.dart';

abstract class OutfitRepository {
  Future<Outfit> generateOutfit({required String mood, required String event, List<String>? excludeIds});
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20});
  Future<Outfit> getOutfit(String id);
  Future<void> toggleFavorite(String id);
  Future<void> logWorn(String id);
  Future<List<Outfit>> getFavorites();
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20});
}
