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
import 'package:stylo_ai/features/wardrobe/presentation/screens/garment_detail_screen.dart';

// ── Fake repository ──────────────────────────────────────────────────────────

class FakeWardrobeRepository implements WardrobeRepository {
  final Garment? garmentToReturn;
  final Exception? errorToThrow;
  bool deleteWasCalled = false;

  FakeWardrobeRepository({this.garmentToReturn, this.errorToThrow});

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async =>
      const PaginatedGarments(
          items: [], total: 0, page: 1, limit: 20, hasMore: false);

  @override
  Future<Garment> getGarment(String id) async {
    if (errorToThrow != null) throw errorToThrow!;
    return garmentToReturn!;
  }

  @override
  Future<void> deleteGarment(String id) async {
    deleteWasCalled = true;
  }

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
      garmentToReturn!;

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
      confidences: const {'Top': 0.95, 'Casual': 0.87},
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget buildTestWidget({
  required FakeWardrobeRepository repo,
  String garmentId = '1',
}) {
  final router = GoRouter(
    initialLocation: '/garment/$garmentId',
    routes: [
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe',
        builder: (_, __) => const Scaffold(body: Text('Wardrobe')),
      ),
      GoRoute(
        path: '/garment/:id',
        name: 'garment-detail',
        builder: (context, state) => GarmentDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      wardrobeRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  group('GarmentDetailScreen', () {
    testWidgets('shows loading state initially with back button', (tester) async {
      final repo = FakeWardrobeRepository(
        garmentToReturn: makeGarment(),
      );

      await tester.pumpWidget(buildTestWidget(repo: repo));
      // Just one pump - the FutureProvider is still loading on first frame
      await tester.pump();

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('shows error state when provider fails', (tester) async {
      final repo = FakeWardrobeRepository(
        errorToThrow: Exception('Not found'),
      );

      await tester.pumpWidget(buildTestWidget(repo: repo));
      // Pump enough to let the future resolve without waiting for animations
      await tester.pump();
      await tester.pump();

      expect(find.text('No se pudo cargar la prenda'), findsOneWidget);
      expect(find.textContaining('Not found'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows garment name, type, and attributes section', (tester) async {
      final repo = FakeWardrobeRepository(
        garmentToReturn: makeGarment(),
      );

      await tester.pumpWidget(buildTestWidget(repo: repo));
      // Pump to let the future resolve; don't use pumpAndSettle because
      // Shimmer and CachedNetworkImage animate indefinitely
      await tester.pump();
      await tester.pump();

      // Name and type visible in the header area
      expect(find.text('Test Top'), findsOneWidget);
      expect(find.text('Top'), findsAtLeastNWidgets(1));
      // Attributes section header
      expect(find.text('Características'), findsOneWidget);
      // First attribute row value (Color = Negro)
      expect(find.text('Negro'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows delete button and opens confirmation dialog', (tester) async {
      final repo = FakeWardrobeRepository(
        garmentToReturn: makeGarment(),
      );

      await tester.pumpWidget(buildTestWidget(repo: repo));
      await tester.pump();
      await tester.pump();

      // Scroll down to reveal the delete button
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Eliminar prenda'),
        200,
        scrollable: scrollable,
      );
      await tester.pump();

      await tester.tap(find.text('Eliminar prenda').first);
      // Pump a few frames to let the dialog open
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirmation dialog should appear
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(
        find.textContaining('Esta acción no se puede deshacer'),
        findsOneWidget,
      );
    });

    testWidgets('shows formatted date', (tester) async {
      final repo = FakeWardrobeRepository(
        garmentToReturn: makeGarment(),
      );

      await tester.pumpWidget(buildTestWidget(repo: repo));
      await tester.pump();
      await tester.pump();

      // createdAt is DateTime(2026, 1, 1) -> "1 ene 2026"
      expect(find.text('1 ene 2026'), findsOneWidget);
    });
  });
}
