import 'package:isar_community/isar.dart';
import '../../../../core/storage/local_db.dart';
import '../../domain/entities/garment.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_remote_datasource.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeRemoteDataSource _remoteDataSource;
  final Isar? _isar;

  WardrobeRepositoryImpl(this._remoteDataSource, {Isar? isar}) : _isar = isar;

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result = await _remoteDataSource.getGarments(
        page: page,
        limit: limit,
        filters: filters,
      );
      // Persist to local cache (first page only for simplicity)
      if (page == 1 && _isar != null) {
        await _cacheGarments(result.items);
      }
      return result;
    } catch (_) {
      // Network failed — return from cache for first page
      if (page == 1 && _isar != null) {
        final cached = await _loadCachedGarments();
        if (cached.isNotEmpty) {
          return PaginatedGarments(
            items: cached,
            total: cached.length,
            page: 1,
            limit: limit,
            hasMore: false,
          );
        }
      }
      rethrow;
    }
  }

  Future<void> _cacheGarments(List<Garment> garments) async {
    final isar = _isar!;
    await isar.writeTxn(() async {
      for (final garment in garments) {
        final existing = await isar.garmentCaches
            .where()
            .garmentIdEqualTo(garment.id)
            .findFirst();
        final cache = existing ?? GarmentCache();
        cache
          ..garmentId = garment.id
          ..name = garment.name
          ..imageUrl = garment.imageUrl
          ..thumbnailUrl = garment.thumbnailUrl
          ..type = garment.type
          ..color = garment.color
          ..style = garment.style
          ..material = garment.material
          ..season = garment.season
          ..tags = garment.tags
          ..userId = garment.userId
          ..createdAt = garment.createdAt
          ..updatedAt = garment.updatedAt;
        await isar.garmentCaches.put(cache);
      }
    });
  }

  Future<List<Garment>> _loadCachedGarments() async {
    final cached = await _isar!.garmentCaches.where().findAll();
    return cached
        .map(
          (c) => Garment(
            id: c.garmentId,
            name: c.name,
            imageUrl: c.imageUrl,
            thumbnailUrl: c.thumbnailUrl,
            type: c.type,
            color: c.color,
            style: c.style,
            material: c.material,
            season: c.season,
            tags: c.tags,
            userId: c.userId,
            createdAt: c.createdAt,
            updatedAt: c.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<Garment> getGarment(String id) => _remoteDataSource.getGarment(id);

  @override
  Future<ScanJobResult> scanGarment(String imagePath) =>
      _remoteDataSource.scanGarment(imagePath);

  @override
  Future<ScanJobStatus> checkScanJob(String jobId) =>
      _remoteDataSource.checkScanJob(jobId);

  @override
  Future<Garment> updateGarment(String id, Map<String, dynamic> data) =>
      _remoteDataSource.updateGarment(id, data);

  @override
  Future<void> deleteGarment(String id) =>
      _remoteDataSource.deleteGarment(id);

  @override
  Future<List<Garment>> searchGarments(String query) =>
      _remoteDataSource.searchGarments(query);
}
