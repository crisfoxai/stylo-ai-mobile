import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';

void main() {
  final now = DateTime(2024, 6, 1);

  OutfitGarment makeOG({
    String garmentId = 'g1',
    String? thumbnailUrl,
    String type = 'top',
    String color = 'white',
    String style = 'casual',
  }) {
    return OutfitGarment(
      garmentId: garmentId,
      thumbnailUrl: thumbnailUrl,
      type: type,
      color: color,
      style: style,
    );
  }

  Outfit makeOutfit({
    String id = 'outfit-1',
    String name = 'Summer Look',
    List<OutfitGarment>? garments,
    String? mood,
    String? event,
    String? weatherContext,
    double? score,
    String? rationale,
    bool isFavorite = false,
    DateTime? wornAt,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id,
      name: name,
      garments: garments ?? [makeOG()],
      mood: mood,
      event: event,
      weatherContext: weatherContext,
      score: score,
      rationale: rationale,
      isFavorite: isFavorite,
      wornAt: wornAt,
      createdAt: createdAt ?? now,
    );
  }

  group('OutfitGarment', () {
    group('construction', () {
      test('creates with all required fields', () {
        final og = makeOG(garmentId: 'g-abc', type: 'bottom', color: 'blue', style: 'formal');
        expect(og.garmentId, 'g-abc');
        expect(og.type, 'bottom');
        expect(og.color, 'blue');
        expect(og.style, 'formal');
        expect(og.thumbnailUrl, isNull);
      });

      test('stores thumbnailUrl when provided', () {
        final og = makeOG(thumbnailUrl: 'https://cdn.example.com/thumb.jpg');
        expect(og.thumbnailUrl, 'https://cdn.example.com/thumb.jpg');
      });
    });

    group('Equatable', () {
      test('equal when all props match', () {
        expect(makeOG(), equals(makeOG()));
      });

      test('not equal when garmentId differs', () {
        expect(makeOG(garmentId: 'g1'), isNot(equals(makeOG(garmentId: 'g2'))));
      });

      test('not equal when color differs', () {
        expect(makeOG(color: 'red'), isNot(equals(makeOG(color: 'blue'))));
      });

      test('props has 5 entries', () {
        expect(makeOG().props.length, 5);
      });
    });
  });

  group('Outfit', () {
    group('construction', () {
      test('creates with required fields', () {
        final outfit = makeOutfit();
        expect(outfit.id, 'outfit-1');
        expect(outfit.name, 'Summer Look');
        expect(outfit.garments.length, 1);
        expect(outfit.isFavorite, isFalse);
        expect(outfit.createdAt, now);
      });

      test('optional fields default to null/false', () {
        final outfit = makeOutfit();
        expect(outfit.mood, isNull);
        expect(outfit.event, isNull);
        expect(outfit.weatherContext, isNull);
        expect(outfit.score, isNull);
        expect(outfit.rationale, isNull);
        expect(outfit.wornAt, isNull);
      });

      test('stores all optional fields when provided', () {
        final worn = DateTime(2024, 5, 20);
        final outfit = makeOutfit(
          mood: 'confident',
          event: 'work',
          weatherContext: 'sunny 25°C',
          score: 0.92,
          rationale: 'Perfect for a hot day',
          isFavorite: true,
          wornAt: worn,
        );
        expect(outfit.mood, 'confident');
        expect(outfit.event, 'work');
        expect(outfit.weatherContext, 'sunny 25°C');
        expect(outfit.score, closeTo(0.92, 0.001));
        expect(outfit.rationale, 'Perfect for a hot day');
        expect(outfit.isFavorite, isTrue);
        expect(outfit.wornAt, worn);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated isFavorite', () {
        final outfit = makeOutfit(isFavorite: false);
        final updated = outfit.copyWith(isFavorite: true);
        expect(updated.isFavorite, isTrue);
        expect(updated.id, outfit.id);
      });

      test('returns new instance with updated name', () {
        final outfit = makeOutfit(name: 'Old Name');
        final updated = outfit.copyWith(name: 'New Name');
        expect(updated.name, 'New Name');
        expect(updated.id, outfit.id);
      });

      test('returns new instance with updated wornAt', () {
        final outfit = makeOutfit();
        final worn = DateTime(2024, 7, 1);
        final updated = outfit.copyWith(wornAt: worn);
        expect(updated.wornAt, worn);
      });

      test('does not mutate original outfit', () {
        final outfit = makeOutfit(isFavorite: false);
        outfit.copyWith(isFavorite: true);
        expect(outfit.isFavorite, isFalse);
      });
    });

    group('Equatable', () {
      test('equal when all props match', () {
        expect(makeOutfit(), equals(makeOutfit()));
      });

      test('not equal when id differs', () {
        expect(
          makeOutfit(id: 'o1'),
          isNot(equals(makeOutfit(id: 'o2'))),
        );
      });

      test('not equal when isFavorite differs', () {
        expect(
          makeOutfit(isFavorite: false),
          isNot(equals(makeOutfit(isFavorite: true))),
        );
      });

      test('props has 11 entries', () {
        expect(makeOutfit().props.length, 11);
      });
    });
  });
}
