import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';

void main() {
  final now = DateTime(2026, 3, 31);

  group('Outfit.copyWith', () {
    final outfit = Outfit(
      id: '1',
      name: 'Original',
      garments: const [],
      mood: 'casual',
      event: 'work',
      isFavorite: false,
      createdAt: now,
    );

    test('copies with new name', () {
      final copy = outfit.copyWith(name: 'Updated');
      expect(copy.name, 'Updated');
      expect(copy.id, '1');
    });

    test('copies with isFavorite toggled', () {
      final copy = outfit.copyWith(isFavorite: true);
      expect(copy.isFavorite, isTrue);
      expect(copy.name, 'Original');
    });

    test('copies with new garments', () {
      final garments = [
        const OutfitGarment(
          garmentId: 'g1',
          type: 'top',
          color: 'blue',
          style: 'casual',
        ),
      ];
      final copy = outfit.copyWith(garments: garments);
      expect(copy.garments.length, 1);
      expect(copy.garments.first.garmentId, 'g1');
    });

    test('copies with wornAt', () {
      final wornDate = DateTime(2026, 4, 1);
      final copy = outfit.copyWith(wornAt: wornDate);
      expect(copy.wornAt, wornDate);
    });

    test('preserves all fields when no overrides', () {
      final copy = outfit.copyWith();
      expect(copy, outfit);
    });
  });

  group('OutfitGarment equatable', () {
    test('equal instances have same props', () {
      const a = OutfitGarment(
        garmentId: 'g1',
        type: 'top',
        color: 'blue',
        style: 'casual',
      );
      const b = OutfitGarment(
        garmentId: 'g1',
        type: 'top',
        color: 'blue',
        style: 'casual',
      );
      expect(a, b);
    });

    test('different garments are not equal', () {
      const a = OutfitGarment(
        garmentId: 'g1',
        type: 'top',
        color: 'blue',
        style: 'casual',
      );
      const b = OutfitGarment(
        garmentId: 'g2',
        type: 'bottom',
        color: 'red',
        style: 'formal',
      );
      expect(a, isNot(b));
    });

    test('thumbnailUrl included in props', () {
      const a = OutfitGarment(
        garmentId: 'g1',
        thumbnailUrl: 'https://a.com/1.jpg',
        type: 'top',
        color: 'blue',
        style: 'casual',
      );
      const b = OutfitGarment(
        garmentId: 'g1',
        thumbnailUrl: 'https://a.com/2.jpg',
        type: 'top',
        color: 'blue',
        style: 'casual',
      );
      expect(a, isNot(b));
    });
  });
}
