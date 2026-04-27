import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';
import 'package:stylo_ai/features/outfits/domain/entities/wardrobe_count.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/detection_result.dart';
import 'package:stylo_ai/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:stylo_ai/features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'package:stylo_ai/features/wardrobe/presentation/screens/garment_preview_screen.dart';

// ── Fake repository ──────────────────────────────────────────────────────────

class FakeWardrobeRepository implements WardrobeRepository {
  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async =>
      const PaginatedGarments(
          items: [], total: 0, page: 1, limit: 20, hasMore: false);

  @override
  Future<Garment> getGarment(String id) async => throw UnimplementedError();

  @override
  Future<void> deleteGarment(String id) async {}

  @override
  Future<List<Garment>> searchGarments(String query) async => [];

  @override
  Future<ScanJobResult> scanGarment(String imagePath) async =>
      const ScanJobResult(jobId: 'job-1', status: 'processing');

  @override
  Future<ScanJobStatus> checkScanJob(String jobId) async =>
      ScanJobStatus(jobId: jobId, status: 'processing');

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

// ── Test scan notifier that does NOT actually call repository ────────────────

class TestScanNotifier extends GarmentScanNotifier {
  TestScanNotifier(ScanState initialState) : super(FakeWardrobeRepository()) {
    state = initialState;
  }

  bool startScanCalled = false;

  @override
  Future<void> startScan(String imagePath) async {
    startScanCalled = true;
  }

  @override
  void reset() {
    state = const ScanState();
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Garment makeGarment({String id = '1'}) => Garment(
      id: id,
      name: 'Test Top',
      imageUrl: 'https://example.com/img.jpg',
      type: 'Top',
      color: 'Negro',
      style: 'Casual',
      material: 'Algodón',
      season: 'Verano',
      tags: const ['casual', 'negro'],
      userId: 'u1',
      confidences: const {'Top': 0.95},
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget buildTestWidget({
  required TestScanNotifier scanNotifier,
  String imagePath = '/tmp/test_image.jpg',
}) {
  final router = GoRouter(
    initialLocation: '/preview',
    routes: [
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe',
        builder: (_, __) => const Scaffold(body: Text('Wardrobe')),
      ),
      GoRoute(
        path: '/preview',
        name: 'preview',
        builder: (_, __) => GarmentPreviewScreen(imagePath: imagePath),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      wardrobeRepositoryProvider.overrideWithValue(FakeWardrobeRepository()),
      garmentScanProvider.overrideWith((_) => scanNotifier),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  group('GarmentPreviewScreen', () {
    void setPhoneSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1284, 2778);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('shows processing state with progress text', (tester) async {
      setPhoneSize(tester);
      final scanNotifier = TestScanNotifier(
        const ScanState(step: ScanStep.processing),
      );

      await tester.pumpWidget(buildTestWidget(scanNotifier: scanNotifier));
      await tester.pump();

      expect(find.text('Vista previa'), findsOneWidget);
      expect(find.text('Clasificando prenda con IA...'), findsOneWidget);
      expect(find.text('Volver a intentar'), findsOneWidget);
      expect(find.text('Descartar'), findsOneWidget);
      expect(find.text('Agregar al guardarropa'), findsNothing);
    });

    testWidgets('shows classification results when scan is done', (tester) async {
      setPhoneSize(tester);
      final garment = makeGarment();
      final scanNotifier = TestScanNotifier(
        ScanState(step: ScanStep.done, result: garment),
      );

      await tester.pumpWidget(buildTestWidget(scanNotifier: scanNotifier));
      await tester.pump();

      expect(find.text('Clasificación IA'), findsOneWidget);
      expect(find.text('Test Top'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Negro'), findsOneWidget);
      expect(find.text('Agregar al guardarropa'), findsOneWidget);
    });

    testWidgets('shows error state with error message', (tester) async {
      setPhoneSize(tester);
      final scanNotifier = TestScanNotifier(
        const ScanState(step: ScanStep.error, errorMessage: 'Server timeout'),
      );

      await tester.pumpWidget(buildTestWidget(scanNotifier: scanNotifier));
      await tester.pump();

      expect(find.text('No se pudo clasificar la prenda'), findsOneWidget);
      expect(find.text('Server timeout'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Agregar al guardarropa'), findsNothing);
    });

    testWidgets('shows uploading state as processing shimmer', (tester) async {
      setPhoneSize(tester);
      final scanNotifier = TestScanNotifier(
        const ScanState(step: ScanStep.uploading),
      );

      await tester.pumpWidget(buildTestWidget(scanNotifier: scanNotifier));
      await tester.pump();

      expect(find.text('Clasificando prenda con IA...'), findsOneWidget);
    });

    testWidgets('back button is present in app bar', (tester) async {
      setPhoneSize(tester);
      final scanNotifier = TestScanNotifier(
        const ScanState(step: ScanStep.idle),
      );

      await tester.pumpWidget(buildTestWidget(scanNotifier: scanNotifier));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });
  });
}
