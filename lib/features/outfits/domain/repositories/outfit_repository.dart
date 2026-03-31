import '../entities/outfit.dart';

abstract class OutfitRepository {
  Future<Outfit> generateOutfit({required String mood, required String event});
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20});
  Future<Outfit> getOutfit(String id);
  Future<Outfit> toggleFavorite(String id);
  Future<Outfit> logWorn(String id);
  Future<List<Outfit>> getFavorites();
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20});
}
