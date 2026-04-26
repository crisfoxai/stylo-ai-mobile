import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/screens/outfit_history_screen.dart';

// ── Fake Repository ──────────────────────────────────────────────────────────

class FakeOutfitRepository implements OutfitRepository {
  List<Outfit> historyOutfits;

  FakeOutfitRepository({this.historyOutfits = const []});

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async =>
      historyOutfits;

  @override
  Future<List<Outfit>> getFavorites() async => [];

  @override
  Future<Outfit> getOutfit(String id) async =>
      historyOutfits.firstWhere((o) => o.id == id);

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async =>
      historyOutfits;

  @override
  Future<Outfit> toggleFavorite(String id) async =>
      historyOutfits.firstWhere((o) => o.id == id);

  @override
  Future<Outfit> logWorn(String id) async =>
      historyOutfits.firstWhere((o) => o.id == id);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Outfit _makeOutfit({
  String id = '1',
  String name = 'Test Outfit',
  bool isFavorite = false,
  DateTime? createdAt,
  DateTime? wornAt,
}) {
  return Outfit(
    id: id,
    name: name,
    garments: const [
      OutfitGarment(
          garmentId: 'g1', type: 'Top', color: 'Negro', style: 'Casual'),
    ],
    mood: 'Casual',
    event: 'Diario',
    score: 8.5,
    rationale: 'Test rationale',
    isFavorite: isFavorite,
    wornAt: wornAt,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

Widget _buildWidget({List<Outfit> historyOutfits = const []}) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(
        path: '/history',
        builder: (_, __) => const OutfitHistoryScreen(),
      ),
      GoRoute(
        path: '/outfits',
        builder: (_, __) => const Scaffold(body: Text('Outfits')),
      ),
      GoRoute(
        path: '/outfits/:id',
        builder: (_, __) => const Scaffold(body: Text('Detail')),
      ),
    ],
  );

  final fakeRepo = FakeOutfitRepository(historyOutfits: historyOutfits);

  return ProviderScope(
    overrides: [
      outfitRepositoryProvider.overrideWithValue(fakeRepo),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OutfitHistoryScreen', () {
    testWidgets('renders Historial title in app bar', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Historial'), findsOneWidget);
    });

    testWidgets('shows empty state when outfits list is empty',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sin historial aún'), findsOneWidget);
      expect(find.text('Generar un outfit'), findsOneWidget);
    });

    testWidgets('shows empty state helper text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Cuando uses un outfit, aparecerá aquí con la fecha en que lo llevaste puesto'),
        findsOneWidget,
      );
    });

    testWidgets('renders outfit tiles when outfits exist', (tester) async {
      final outfits = [
        _makeOutfit(
            id: '1', name: 'Outfit Lunes', createdAt: DateTime(2026, 1, 5)),
        _makeOutfit(
            id: '2', name: 'Outfit Martes', createdAt: DateTime(2026, 1, 5)),
      ];
      await tester.pumpWidget(_buildWidget(historyOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('Outfit Lunes'), findsOneWidget);
      expect(find.text('Outfit Martes'), findsOneWidget);
    });

    testWidgets('shows garment count per outfit tile', (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Single Garment'),
      ];
      await tester.pumpWidget(_buildWidget(historyOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('1 prendas'), findsOneWidget);
    });

    testWidgets('shows mood and event text on outfit tiles', (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Mood Event Outfit'),
      ];
      await tester.pumpWidget(_buildWidget(historyOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('Casual \u00b7 Diario'), findsOneWidget);
    });
  });
}
