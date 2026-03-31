import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_history_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/screens/home_dashboard_screen.dart';

// ── Fake Repository ──────────────────────────────────────────────────────────

class FakeOutfitRepository implements OutfitRepository {
  List<Outfit> historyOutfits;
  List<Outfit> favoriteOutfits;

  FakeOutfitRepository({
    this.historyOutfits = const [],
    this.favoriteOutfits = const [],
  });

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) async =>
      historyOutfits;

  @override
  Future<List<Outfit>> getFavorites() async => favoriteOutfits;

  @override
  Future<Outfit> getOutfit(String id) async => historyOutfits.first;

  @override
  Future<Outfit> generateOutfit(
          {required String mood, required String event}) =>
      throw UnimplementedError();

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) async =>
      historyOutfits;

  @override
  Future<Outfit> toggleFavorite(String id) async => historyOutfits.first;

  @override
  Future<Outfit> logWorn(String id) async => historyOutfits.first;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Outfit _makeOutfit({
  String id = '1',
  String name = 'Test Outfit',
  bool isFavorite = false,
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
    createdAt: DateTime(2026, 1, 1),
  );
}

User _makeUser() => User(
      id: 'u1',
      email: 'test@stylo.ai',
      firstName: 'Carlos',
      lastName: 'Test',
      createdAt: DateTime(2024),
    );

Widget _buildWidget({
  User? user,
  List<Outfit> historyOutfits = const [],
  List<Outfit> favoriteOutfits = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/outfits',
        builder: (_, __) => const Scaffold(body: Text('Outfits')),
      ),
      GoRoute(
        path: '/outfits/history',
        builder: (_, __) => const Scaffold(body: Text('History')),
      ),
      GoRoute(
        path: '/outfits/favorites',
        builder: (_, __) => const Scaffold(body: Text('Favorites')),
      ),
      GoRoute(
        path: '/outfits/:id',
        builder: (_, __) => const Scaffold(body: Text('Detail')),
      ),
      GoRoute(
        path: '/scan',
        builder: (_, __) => const Scaffold(body: Text('Scan')),
      ),
      GoRoute(
        path: '/wardrobe',
        builder: (_, __) => const Scaffold(body: Text('Wardrobe')),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const Scaffold(body: Text('Profile')),
      ),
    ],
  );

  final fakeRepo = FakeOutfitRepository(
    historyOutfits: historyOutfits,
    favoriteOutfits: favoriteOutfits,
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(user),
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
  group('HomeDashboardScreen', () {
    testWidgets('renders greeting text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // The greeting depends on the current hour. One of these must exist.
      final greetings = ['Buenos días', 'Buenas tardes', 'Buenas noches'];
      final found = greetings.any(
        (g) => find.text(g).evaluate().isNotEmpty,
      );
      expect(found, isTrue);
    });

    testWidgets('renders user first name when user is present',
        (tester) async {
      await tester.pumpWidget(_buildWidget(user: _makeUser()));
      await tester.pumpAndSettle();

      expect(find.text('Carlos'), findsOneWidget);
    });

    testWidgets('renders fallback name when user is null', (tester) async {
      await tester.pumpWidget(_buildWidget(user: null));
      await tester.pumpAndSettle();

      expect(find.text('Stylo'), findsOneWidget);
    });

    testWidgets('renders quick action labels', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Acciones rápidas'), findsOneWidget);
      expect(find.text('Escanear'), findsOneWidget);
      expect(find.text('Nuevo outfit'), findsOneWidget);
      expect(find.text('Guardarropa'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
    });

    testWidgets('shows empty state when no outfits exist', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Aún no tenés outfits'), findsOneWidget);
      expect(find.text('Generá tu primer outfit con IA'), findsOneWidget);
    });

    testWidgets('renders outfit of the day card with outfit name',
        (tester) async {
      final outfit = _makeOutfit(name: 'Mi Outfit Genial');
      await tester.pumpWidget(_buildWidget(
        historyOutfits: [outfit],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Outfit del día'), findsOneWidget);
      expect(find.text('Mi Outfit Genial'), findsAtLeastNWidgets(1));
      expect(find.text('Ver outfit'), findsOneWidget);
    });

    testWidgets('renders recent history section when outfits exist',
        (tester) async {
      final outfits = [
        _makeOutfit(id: '1', name: 'Outfit Uno'),
        _makeOutfit(id: '2', name: 'Outfit Dos'),
      ];
      await tester.pumpWidget(_buildWidget(historyOutfits: outfits));
      await tester.pumpAndSettle();

      expect(find.text('Historial reciente'), findsOneWidget);
      expect(find.text('Ver todo'), findsWidgets);
    });

    testWidgets('renders favorites section when favorite outfits exist',
        (tester) async {
      final favOutfit =
          _makeOutfit(id: '3', name: 'Fav Outfit', isFavorite: true);
      await tester.pumpWidget(_buildWidget(
        favoriteOutfits: [favOutfit],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Outfits favoritos'), findsOneWidget);
      expect(find.text('Fav Outfit'), findsOneWidget);
    });
  });
}
