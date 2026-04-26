import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/screens/favorites_screen.dart';

// ── Fake Repository ──────────────────────────────────────────────────────────

class FakeOutfitRepository implements OutfitRepository {
  List<Outfit> favoriteOutfits;

  FakeOutfitRepository({this.favoriteOutfits = const []});

  @override
  Future<List<Outfit>> getFavorites() async => favoriteOutfits;

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async => [];

  @override
  Future<Outfit> getOutfit(String id) async =>
      favoriteOutfits.firstWhere((o) => o.id == id);

  @override
  Future<Outfit> generateOutfit({
    required String mood,
    required String event,
    List<String>? excludeIds,
  }) => throw UnimplementedError();

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async => [];

  @override
  Future<void> toggleFavorite(String id) async {}

  @override
  Future<void> logWorn(String id) async {}
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Outfit _makeOutfit({
  String id = '1',
  String name = 'Test Outfit',
  bool isFavorite = true,
  double? score = 8.5,
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
    score: score,
    rationale: 'Test rationale',
    isFavorite: isFavorite,
    createdAt: DateTime(2026, 1, 1),
  );
}

Widget _buildWidget({List<Outfit> favoriteOutfits = const []}) {
  final router = GoRouter(
    initialLocation: '/favorites',
    routes: [
      GoRoute(
        path: '/favorites',
        builder: (_, __) => const FavoritesScreen(),
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

  final fakeRepo = FakeOutfitRepository(favoriteOutfits: favoriteOutfits);

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
  group('FavoritesScreen', () {
    testWidgets('renders Favoritos title in app bar', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('shows empty state when no favorites exist', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sin favoritos aún'), findsOneWidget);
      expect(find.text('Generar un outfit'), findsOneWidget);
    });

    testWidgets('shows empty state helper text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Guardá los outfits que más te gusten para encontrarlos fácilmente'),
        findsOneWidget,
      );
    });

    testWidgets('renders grid of favorite outfit cards', (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Fav One'),
        _makeOutfit(id: '2', name: 'Fav Two'),
        _makeOutfit(id: '3', name: 'Fav Three'),
      ];
      await tester.pumpWidget(_buildWidget(favoriteOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('Fav One'), findsOneWidget);
      expect(find.text('Fav Two'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('displays score on favorite cards', (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Scored Outfit', score: 9.2),
      ];
      await tester.pumpWidget(_buildWidget(favoriteOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('9.2'), findsOneWidget);
    });

    testWidgets('displays mood and event on favorite cards', (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Tagged Outfit'),
      ];
      await tester.pumpWidget(_buildWidget(favoriteOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('Casual \u00b7 Diario'), findsOneWidget);
    });
  });
}
