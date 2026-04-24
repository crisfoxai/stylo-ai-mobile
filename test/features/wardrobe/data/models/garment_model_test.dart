import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/wardrobe/data/models/garment_model.dart';
import 'package:stylo_ai/features/wardrobe/domain/entities/garment.dart';

void main() {
  group('GarmentModel', () {
    final fixedDate = DateTime.parse('2024-03-10T08:00:00.000Z');

    final fullJson = <String, dynamic>{
      'id': 'garment-abc',
      'name': 'Blue Jeans',
      'imageUrl': 'https://example.com/jeans.jpg',
      'thumbnailUrl': 'https://example.com/jeans_thumb.jpg',
      'type': 'bottom',
      'color': 'blue',
      'style': 'casual',
      'material': 'denim',
      'season': 'all',
      'tags': ['denim', 'casual', 'everyday'],
      'userId': 'user-xyz',
      'confidences': {'color': 0.92, 'type': 0.88, 'style': 0.75},
      'createdAt': '2024-03-10T08:00:00.000Z',
      'updatedAt': '2024-03-10T08:00:00.000Z',
    };

    group('fromJson', () {
      test('parses a fully populated JSON object correctly', () {
        final model = GarmentModel.fromJson(fullJson);
        expect(model.id, 'garment-abc');
        expect(model.name, 'Blue Jeans');
        expect(model.imageUrl, 'https://example.com/jeans.jpg');
        expect(model.thumbnailUrl, 'https://example.com/jeans_thumb.jpg');
        expect(model.type, 'bottom');
        expect(model.color, 'blue');
        expect(model.style, 'casual');
        expect(model.material, 'denim');
        expect(model.season, 'all');
        expect(model.tags, ['denim', 'casual', 'everyday']);
        expect(model.userId, 'user-xyz');
        expect(model.createdAt, fixedDate);
        expect(model.updatedAt, fixedDate);
      });

      test('parses confidences as Map<String, double>', () {
        final model = GarmentModel.fromJson(fullJson);
        expect(model.confidences, isNotNull);
        expect(model.confidences!['color'], closeTo(0.92, 0.001));
        expect(model.confidences!['type'], closeTo(0.88, 0.001));
        expect(model.confidences!['style'], closeTo(0.75, 0.001));
      });

      test('handles confidences with integer values', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['confidences'] = {'color': 1, 'type': 0};
        final model = GarmentModel.fromJson(json);
        expect(model.confidences!['color'], 1.0);
        expect(model.confidences!['color'], isA<double>());
      });

      test('sets confidences to null when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('confidences');
        final model = GarmentModel.fromJson(json);
        expect(model.confidences, isNull);
      });

      test('sets confidences to null when explicitly null', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['confidences'] = null;
        final model = GarmentModel.fromJson(json);
        expect(model.confidences, isNull);
      });

      test('defaults tags to empty list when missing', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('tags');
        expect(GarmentModel.fromJson(json).tags, isEmpty);
      });

      test('sets optional string fields to null when absent', () {
        final json = Map<String, dynamic>.from(fullJson)
          ..remove('thumbnailUrl')
          ..remove('color')
          ..remove('style')
          ..remove('material')
          ..remove('season');
        final model = GarmentModel.fromJson(json);
        expect(model.thumbnailUrl, isNull);
        expect(model.color, isNull);
        expect(model.style, isNull);
        expect(model.material, isNull);
        expect(model.season, isNull);
      });

    });

    group('toJson', () {
      late GarmentModel model;

      setUp(() {
        model = GarmentModel.fromJson(fullJson);
      });

      test('serializes all fields', () {
        final json = model.toJson();
        expect(json['id'], 'garment-abc');
        expect(json['name'], 'Blue Jeans');
        expect(json['imageUrl'], 'https://example.com/jeans.jpg');
        expect(json['thumbnailUrl'], 'https://example.com/jeans_thumb.jpg');
        expect(json['type'], 'bottom');
        expect(json['color'], 'blue');
        expect(json['style'], 'casual');
        expect(json['material'], 'denim');
        expect(json['season'], 'all');
        expect(json['tags'], ['denim', 'casual', 'everyday']);
        expect(json['userId'], 'user-xyz');
        expect(json['createdAt'], fixedDate.toIso8601String());
        expect(json['updatedAt'], fixedDate.toIso8601String());
      });

      test('serializes null optional fields as null', () {
        final sparseJson = Map<String, dynamic>.from(fullJson)
          ..remove('thumbnailUrl')
          ..remove('color')
          ..remove('style')
          ..remove('material')
          ..remove('season')
          ..remove('confidences');
        final sparseModel = GarmentModel.fromJson(sparseJson);
        final json = sparseModel.toJson();
        expect(json['thumbnailUrl'], isNull);
        expect(json['color'], isNull);
        expect(json['confidences'], isNull);
      });

      test('round-trips correctly through fromJson/toJson', () {
        final json = model.toJson();
        final restored = GarmentModel.fromJson(json);
        expect(restored.id, model.id);
        expect(restored.name, model.name);
        expect(restored.type, model.type);
        expect(restored.tags, model.tags);
        expect(restored.confidences!['color'], model.confidences!['color']);
      });
    });

    group('inheritance', () {
      test('GarmentModel is a subtype of Garment', () {
        expect(GarmentModel.fromJson(fullJson), isA<Garment>());
      });
    });
  });
}
