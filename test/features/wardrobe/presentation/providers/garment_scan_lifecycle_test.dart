import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/detection_result.dart';
import 'package:stylo_ai/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:stylo_ai/features/outfits/domain/entities/wardrobe_count.dart';
import 'package:stylo_ai/features/wardrobe/presentation/providers/wardrobe_provider.dart';

class _FakeWardrobeRepository implements WardrobeRepository {
  int checkJobCallCount = 0;
  bool shouldFail = false;
  String scanJobStatus = 'processing';
  Garment? garmentResult;

  @override
  Future<ScanJobResult> scanGarment(String imagePath) async {
    return const ScanJobResult(jobId: 'job-123', status: 'processing');
  }

  @override
  Future<ScanJobStatus> checkScanJob(String jobId) async {
    checkJobCallCount++;
    if (shouldFail) {
      throw Exception('Network error');
    }
    return ScanJobStatus(
      jobId: jobId,
      status: scanJobStatus,
      garment: scanJobStatus == 'done' ? garmentResult : null,
    );
  }

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async =>
      const PaginatedGarments(items: [], total: 0, page: 1, limit: 20, hasMore: false);

  @override
  Future<Garment> getGarment(String id) async => throw UnimplementedError();

  @override
  Future<void> deleteGarment(String id) async {}

  @override
  Future<List<Garment>> searchGarments(String query) async => [];

  @override
  Future<Garment> updateGarment(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<WardrobeCount> getCount() async =>
      const WardrobeCount(count: 0, threshold: 5, state: 'empty');

  @override
  Future<DetectionResult> detectFromPhoto(String filePath) async =>
      throw UnimplementedError();

  @override
  Future<List<String>> confirmDetection(
          String photoKey, List<DetectedGarmentEdit> garments) async =>
      [];
}

void main() {
  group('GarmentScanNotifier lifecycle', () {
    late ProviderContainer container;
    late _FakeWardrobeRepository repo;

    setUp(() {
      repo = _FakeWardrobeRepository();
      container = ProviderContainer(
        overrides: [
          wardrobeRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('setImagePath sets step to capturing', () {
      final notifier = container.read(garmentScanProvider.notifier);
      notifier.setImagePath('/tmp/photo.jpg');
      final state = container.read(garmentScanProvider);
      expect(state.step, ScanStep.capturing);
      expect(state.imagePath, '/tmp/photo.jpg');
    });

    test('startScan transitions to uploading then processing', () async {
      final notifier = container.read(garmentScanProvider.notifier);
      await notifier.startScan('/tmp/photo.jpg');
      final state = container.read(garmentScanProvider);
      expect(state.step, ScanStep.processing);
      expect(state.jobId, 'job-123');
    });

    test('startScan handles error', () async {
      final failRepo = _FailingScanRepo();
      final failContainer = ProviderContainer(
        overrides: [
          wardrobeRepositoryProvider.overrideWithValue(failRepo),
        ],
      );
      addTearDown(failContainer.dispose);

      final notifier = failContainer.read(garmentScanProvider.notifier);
      await notifier.startScan('/tmp/photo.jpg');
      final state = failContainer.read(garmentScanProvider);
      expect(state.step, ScanStep.error);
      expect(state.errorMessage, isNotNull);
    });

    test('reset clears state and cancels timer', () async {
      final notifier = container.read(garmentScanProvider.notifier);
      await notifier.startScan('/tmp/photo.jpg');
      notifier.reset();
      final state = container.read(garmentScanProvider);
      expect(state.step, ScanStep.idle);
      expect(state.imagePath, isNull);
      expect(state.jobId, isNull);
    });

    test('dispose cancels polling timer', () {
      final tempContainer = ProviderContainer(
        overrides: [
          wardrobeRepositoryProvider.overrideWithValue(repo),
        ],
      );
      tempContainer.read(garmentScanProvider.notifier);
      tempContainer.dispose();
      // No exception = success
    });
  });
}

class _FailingScanRepo extends _FakeWardrobeRepository {
  @override
  Future<ScanJobResult> scanGarment(String imagePath) async {
    throw Exception('Upload failed');
  }
}
