import '../entities/garment.dart';
import '../entities/detection_result.dart';
import '../../../outfits/domain/entities/wardrobe_count.dart';

abstract class WardrobeRepository {
  Future<WardrobeCount> getCount();

  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  Future<Garment> getGarment(String id);

  Future<ScanJobResult> scanGarment(String imagePath);

  Future<ScanJobStatus> checkScanJob(String jobId);

  Future<Garment> updateGarment(String id, Map<String, dynamic> data);

  Future<void> deleteGarment(String id);

  Future<List<Garment>> searchGarments(String query);

  Future<DetectionResult> detectFromPhoto(String filePath);

  Future<List<String>> confirmDetection(
    String photoKey,
    List<DetectedGarmentEdit> garments,
  );
}

class PaginatedGarments {
  final List<Garment> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  const PaginatedGarments({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

class ScanJobResult {
  final String jobId;
  final String status;

  const ScanJobResult({
    required this.jobId,
    required this.status,
  });
}

class ScanJobStatus {
  final String jobId;
  final String status;
  final Garment? garment;
  final String? errorMessage;

  const ScanJobStatus({
    required this.jobId,
    required this.status,
    this.garment,
    this.errorMessage,
  });

  bool get isComplete => status == 'done' || status == 'completed';
  bool get isFailed => status == 'error' || status == 'failed';
  bool get isProcessing => !isComplete && !isFailed;
}
