import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';
import 'package:stylo_ai/features/wardrobe/domain/repositories/wardrobe_repository.dart';
import 'package:stylo_ai/features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'package:stylo_ai/features/wardrobe/presentation/screens/wardrobe_grid_screen.dart';

// ── Fake repository ──────────────────────────────────────────────────────────

class FakeWardrobeRepository implements WardrobeRepository {
  List<Garment> garments;
  Exception? errorToThrow;

  FakeWardrobeRepository({List<Garment>? garments})
      : garments = garments ?? [];

  @override
  Future<PaginatedGarments> getGarments({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    if (errorToThrow != null) {
      final e = errorToThrow!;
      errorToThrow = null;
      throw e;
    }
    return PaginatedGarments(
      items: garments,
      total: garments.length,
      page: page,
      limit: limit,
      hasMore: false,
    );
  }

  @override
  Future<Garment> getGarment(String id) async =>
      garments.firstWhere((g) => g.id == id);

  @override
  Future<void> deleteGarment(String id) async =>
      garments.removeWhere((g) => g.id == id);

  @override
  Future<List<Garment>> searchGarments(String query) async => garments
      .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  @override
  Future<ScanJobResult> scanGarment(String imagePath) async =>
      const ScanJobResult(jobId: 'job-1', status: 'processing');

  @override
  Future<ScanJobStatus> checkScanJob(String jobId) async =>
      ScanJobStatus(jobId: jobId, status: 'processing');

  @override
  Future<Garment> updateGarment(String id, Map<String, dynamic> data) async =>
      garments.firstWhere((g) => g.id == id);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Garment makeGarment({
  String id = '1',
  String name = 'Test Top',
  String type = 'Top',
}) =>
    Garment(
      id: id,
      name: name,
      imageUrl: 'https://example.com/img.jpg',
      type: type,
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

Widget buildTestWidget(FakeWardrobeRepository repo) {
  final router = GoRouter(
    initialLocation: '/wardrobe',
    routes: [
      GoRoute(
        path: '/wardrobe',
        name: 'wardrobe',
        builder: (_, __) => const WardrobeGridScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (_, __) => const Scaffold(body: Text('Scan Screen')),
      ),
      GoRoute(
        path: '/garment/:id',
        name: 'garment-detail',
        builder: (_, __) => const Scaffold(body: Text('Detail Screen')),
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
  group('WardrobeGridScreen', () {
    testWidgets('shows app bar, search bar, and filter chips', (tester) async {
      final repo = FakeWardrobeRepository(garments: []);

      await tester.pumpWidget(buildTestWidget(repo));
      await tester.pump();

      // App bar title
      expect(find.text('Mi Guardarropa'), findsOneWidget);
      // Search bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar prendas...'), findsOneWidget);
      // Filter chip labels
      expect(find.text('Todas'), findsOneWidget);
      expect(find.text('Tops'), findsOneWidget);
      expect(find.text('Bottoms'), findsOneWidget);
      expect(find.text('Zapatos'), findsOneWidget);
      expect(find.text('Accesorios'), findsOneWidget);
      expect(find.text('Abrigos'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no garments are loaded', (tester) async {
      final repo = FakeWardrobeRepository(garments: []);

      await tester.pumpWidget(buildTestWidget(repo));
      // Let loadGarments complete (called via addPostFrameCallback)
      await tester.pumpAndSettle();

      expect(find.text('Tu guardarropa está vacío'), findsOneWidget);
      expect(find.text('Escanear prenda'), findsOneWidget);
    });

    testWidgets('shows garment tiles after loading', (tester) async {
      final garments = [
        makeGarment(id: '1', name: 'Top Rojo'),
        makeGarment(id: '2', name: 'Pantalón Azul', type: 'Bottom'),
      ];
      final repo = FakeWardrobeRepository(garments: garments);

      await tester.pumpWidget(buildTestWidget(repo));
      // Pump twice: once for the post-frame callback, once for the future
      await tester.pump();
      await tester.pump();

      // Count indicator
      expect(find.text('2 prendas'), findsOneWidget);
      // Garment tile names
      expect(find.text('Top Rojo'), findsOneWidget);
      expect(find.text('Pantalón Azul'), findsOneWidget);
    });

    testWidgets('shows error state with retry button on load failure', (tester) async {
      final repo = FakeWardrobeRepository();
      repo.errorToThrow = Exception('Network error');

      await tester.pumpWidget(buildTestWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Algo salió mal'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('has floating action button with camera icon', (tester) async {
      final repo = FakeWardrobeRepository(garments: []);

      await tester.pumpWidget(buildTestWidget(repo));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      // camera_alt_outlined may appear both in FAB and empty state button;
      // verify the FAB specifically contains the icon
      final fab = find.byType(FloatingActionButton);
      expect(
        find.descendant(of: fab, matching: find.byIcon(Icons.camera_alt_outlined)),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });
  });
}
