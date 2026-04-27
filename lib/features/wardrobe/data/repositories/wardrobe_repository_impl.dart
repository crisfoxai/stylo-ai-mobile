import 'dart:io';
import '../../domain/entities/garment.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_remote_datasource.dart';
import '../../../outfits/domain/entities/wardrobe_count.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeRemoteDataSource _remoteDataSource;

  WardrobeRepositoryImpl(this._remoteDataSource, {Object? isar});

  @override
  Future<WardrobeCount> getCount() => _remoteDataSource.getCount();

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) =>
      _remoteDataSource.getGarments(page: page, limit: limit, filters: filters);

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

  @override
  Future<DetectionResult> detectFromPhoto(String filePath) =>
      _remoteDataSource.detectFromPhoto(File(filePath));

  @override
  Future<List<String>> confirmDetection(
    String photoKey,
    List<DetectedGarmentEdit> garments,
  ) =>
      _remoteDataSource.confirmDetection(photoKey, garments);
}
