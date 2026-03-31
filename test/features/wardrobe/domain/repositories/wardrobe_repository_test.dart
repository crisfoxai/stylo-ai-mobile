import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';
import 'package:stylo_ai/features/wardrobe/domain/repositories/wardrobe_repository.dart';

void main() {
  group('PaginatedGarments', () {
    test('stores all fields correctly', () {
      final garments = PaginatedGarments(
        items: [
          Garment(
            id: 'g1',
            name: 'Shirt',
            imageUrl: 'url',
            type: 'top',
            userId: 'u1',
            tags: const [],
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ],
        total: 50,
        page: 1,
        limit: 20,
        hasMore: true,
      );
      expect(garments.items.length, 1);
      expect(garments.total, 50);
      expect(garments.page, 1);
      expect(garments.limit, 20);
      expect(garments.hasMore, isTrue);
    });
  });

  group('ScanJobResult', () {
    test('stores jobId and status', () {
      const result = ScanJobResult(jobId: 'j1', status: 'processing');
      expect(result.jobId, 'j1');
      expect(result.status, 'processing');
    });
  });

  group('ScanJobStatus', () {
    test('isComplete returns true for done status', () {
      const status = ScanJobStatus(jobId: 'j1', status: 'done');
      expect(status.isComplete, isTrue);
      expect(status.isFailed, isFalse);
      expect(status.isProcessing, isFalse);
    });

    test('isComplete returns true for completed status', () {
      const status = ScanJobStatus(jobId: 'j1', status: 'completed');
      expect(status.isComplete, isTrue);
    });

    test('isFailed returns true for error status', () {
      const status = ScanJobStatus(jobId: 'j1', status: 'error');
      expect(status.isFailed, isTrue);
      expect(status.isComplete, isFalse);
      expect(status.isProcessing, isFalse);
    });

    test('isFailed returns true for failed status', () {
      const status = ScanJobStatus(jobId: 'j1', status: 'failed');
      expect(status.isFailed, isTrue);
    });

    test('isProcessing returns true when not complete or failed', () {
      const status = ScanJobStatus(jobId: 'j1', status: 'processing');
      expect(status.isProcessing, isTrue);
      expect(status.isComplete, isFalse);
      expect(status.isFailed, isFalse);
    });

    test('stores garment when provided', () {
      final garment = Garment(
        id: 'g1',
        name: 'Detected Shirt',
        imageUrl: 'url',
        type: 'top',
        userId: 'u1',
        tags: const [],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final status = ScanJobStatus(
        jobId: 'j1',
        status: 'done',
        garment: garment,
      );
      expect(status.garment, isNotNull);
      expect(status.garment!.name, 'Detected Shirt');
    });

    test('stores errorMessage when provided', () {
      const status = ScanJobStatus(
        jobId: 'j1',
        status: 'error',
        errorMessage: 'Image too blurry',
      );
      expect(status.errorMessage, 'Image too blurry');
    });
  });
}
