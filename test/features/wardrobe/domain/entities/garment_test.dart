import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';

void main() {
  final now = DateTime(2024, 3, 10);

  Garment makeGarment({
    String id = 'garment-1',
    String name = 'White T-Shirt',
    String imageUrl = 'https://example.com/tshirt.jpg',
    String? thumbnailUrl,
    String type = 'top',
    String? color = 'white',
    String? style,
    String? material,
    String? season,
    List<String> tags = const ['casual', 'basic'],
    String userId = 'user-1',
    Map<String, double>? confidences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Garment(
      id: id,
      name: name,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      type: type,
      color: color,
      style: style,
      material: material,
      season: season,
      tags: tags,
      userId: userId,
      confidences: confidences,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('Garment', () {
    group('construction', () {
      test('creates a Garment with all required fields', () {
        final g = makeGarment();
        expect(g.id, 'garment-1');
        expect(g.name, 'White T-Shirt');
        expect(g.imageUrl, 'https://example.com/tshirt.jpg');
        expect(g.type, 'top');
        expect(g.userId, 'user-1');
        expect(g.createdAt, now);
        expect(g.updatedAt, now);
      });

      test('optional fields default to null', () {
        final g = makeGarment(
          thumbnailUrl: null,
          color: null,
          style: null,
          material: null,
          season: null,
          confidences: null,
        );
        expect(g.thumbnailUrl, isNull);
        expect(g.color, isNull);
        expect(g.style, isNull);
        expect(g.material, isNull);
        expect(g.season, isNull);
        expect(g.confidences, isNull);
      });

      test('tags default to empty list', () {
        final g = Garment(
          id: 'g',
          name: 'n',
          imageUrl: 'u',
          type: 't',
          userId: 'uid',
          createdAt: now,
          updatedAt: now,
        );
        expect(g.tags, isEmpty);
      });

      test('creates a Garment with all optional fields populated', () {
        final g = makeGarment(
          thumbnailUrl: 'https://example.com/thumb.jpg',
          color: 'blue',
          style: 'casual',
          material: 'cotton',
          season: 'summer',
          confidences: {'color': 0.95, 'type': 0.87},
        );
        expect(g.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(g.color, 'blue');
        expect(g.style, 'casual');
        expect(g.material, 'cotton');
        expect(g.season, 'summer');
        expect(g.confidences!['color'], closeTo(0.95, 0.001));
      });
    });

    group('Equatable equality', () {
      test('two garments with identical props are equal', () {
        final g1 = makeGarment();
        final g2 = makeGarment();
        expect(g1, equals(g2));
      });

      test('garments with different ids are not equal', () {
        final g1 = makeGarment(id: 'g1');
        final g2 = makeGarment(id: 'g2');
        expect(g1, isNot(equals(g2)));
      });

      test('garments with different names are not equal', () {
        final g1 = makeGarment(name: 'T-Shirt');
        final g2 = makeGarment(name: 'Jeans');
        expect(g1, isNot(equals(g2)));
      });

      test('garments with different types are not equal', () {
        final g1 = makeGarment(type: 'top');
        final g2 = makeGarment(type: 'bottom');
        expect(g1, isNot(equals(g2)));
      });

      test('garments with different tags are not equal', () {
        final g1 = makeGarment(tags: ['casual']);
        final g2 = makeGarment(tags: ['formal']);
        expect(g1, isNot(equals(g2)));
      });
    });

    group('props', () {
      test('props contains all 14 expected fields', () {
        final g = makeGarment();
        expect(g.props.length, 14);
      });

      test('props includes id as first element', () {
        final g = makeGarment(id: 'test-id');
        expect(g.props.first, 'test-id');
      });
    });
  });
}
