import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';
import 'package:stylo_ai/features/outfits/domain/repositories/outfit_repository.dart';
import 'package:stylo_ai/features/outfits/presentation/providers/outfit_generator_provider.dart';
import 'package:stylo_ai/features/outfits/presentation/screens/outfit_detail_screen.dart';

// ── Fake Repository ──────────────────────────────────────────────────────────

class FakeOutfitRepository implements OutfitRepository {
  Outfit? outfitToReturn;
  Exception? errorToThrow;
  Completer<Outfit>? _completer;

  /// When set, getOutfit will wait for the completer to resolve.
  void useCompleter() {
    _completer = Completer<Outfit>();
  }

  void completeWith(Outfit outfit) {
    _completer?.complete(outfit);
  }

  @override
  Future<Outfit> getOutfit(String id) async {
    if (_completer != null) return _completer!.future;
    if (errorToThrow != null) throw errorToThrow!;
    return outfitToReturn!;
  }

  @override
  Future<Outfit> generateOutfit(
          {required String mood, required String event}) =>
      throw UnimplementedError();

  @override
  Future<List<Outfit>> getOutfits({int page = 1, int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<Outfit> toggleFavorite(String id) async => outfitToReturn!;

  @override
  Future<Outfit> logWorn(String id) async => outfitToReturn!;

  @override
  Future<List<Outfit>> getFavorites() => throw UnimplementedError();

  @override
  Future<List<Outfit>> getHistory({int page = 1, int limit = 20}) =>
      throw UnimplementedError();
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
      OutfitGarment(
          garmentId: 'g2', type: 'Bottom', color: 'Azul', style: 'Formal'),
    ],
    mood: 'Casual',
    event: 'Diario',
    weatherContext: 'Soleado',
    score: 8.5,
    rationale: 'Great combination for a casual day out',
    isFavorite: isFavorite,
    wornAt: DateTime(2026, 1, 15),
    createdAt: DateTime(2026, 1, 1),
  );
}

Widget _buildWidget(FakeOutfitRepository repo, {String outfitId = '1'}) {
  return ProviderScope(
    overrides: [
      outfitRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: OutfitDetailScreen(id: outfitId),
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OutfitDetailScreen', () {
    testWidgets('shows loading indicator while fetching outfit',
        (tester) async {
      final repo = FakeOutfitRepository();
      repo.useCompleter();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future and settle
      repo.completeWith(_makeOutfit());
      await tester.pumpAndSettle();
    });

    testWidgets('displays outfit name after data loads', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit(name: 'Elegant Evening');

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Elegant Evening'), findsOneWidget);
    });

    testWidgets('displays score badge', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('8.5'), findsOneWidget);
    });

    testWidgets('displays mood, event, and weather tags', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Casual'), findsOneWidget);
      expect(find.text('Diario'), findsOneWidget);
      expect(find.text('Soleado'), findsOneWidget);
    });

    testWidgets('displays garment list with Prendas heading', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Prendas'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Negro \u00b7 Casual'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.text('Azul \u00b7 Formal'), findsOneWidget);
    });

    testWidgets('displays rationale section', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(
          find.text('Great combination for a casual day out'), findsOneWidget);
    });

    testWidgets('displays error state when fetch fails', (tester) async {
      final repo = FakeOutfitRepository();
      repo.errorToThrow = Exception('Network error');

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Error al cargar el outfit'), findsOneWidget);
    });

    testWidgets('displays Usar hoy button', (tester) async {
      final repo = FakeOutfitRepository();
      repo.outfitToReturn = _makeOutfit();

      await tester.pumpWidget(_buildWidget(repo));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Usar hoy'));
      expect(find.text('Usar hoy'), findsOneWidget);
    });
  });
}
