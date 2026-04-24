import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/outfits/data/models/outfit_model.dart';
import 'package:stylo_ai/features/outfits/domain/entities/outfit.dart';

void main() {
  final fixedDate = DateTime.parse('2024-06-01T12:00:00.000Z');
  final wornDate = DateTime.parse('2024-06-05T09:00:00.000Z');

  final garmentJson = <String, dynamic>{
    'garmentId': 'g-001',
    'thumbnailUrl': 'https://cdn.example.com/g001.jpg',
    'type': 'top',
    'color': 'white',
    'style': 'casual',
  };

  final fullOutfitJson = <String, dynamic>{
    'id': 'outfit-xyz',
    'name': 'Summer Casual',
    'garments': [garmentJson],
    'mood': 'relaxed',
    'event': 'weekend',
    'weatherContext': 'sunny 28°C',
    'score': 0.87,
    'rationale': 'Great match for warm weather',
    'isFavorite': true,
    'wornAt': '2024-06-05T09:00:00.000Z',
    'createdAt': '2024-06-01T12:00:00.000Z',
  };

  group('OutfitGarmentModel', () {
    group('fromJson', () {
      test('parses a fully populated garment JSON', () {
        final model = OutfitGarmentModel.fromJson(garmentJson);
        expect(model.garmentId, 'g-001');
        expect(model.thumbnailUrl, 'https://cdn.example.com/g001.jpg');
        expect(model.type, 'top');
        expect(model.color, 'white');
        expect(model.style, 'casual');
      });

      test('sets thumbnailUrl to null when absent', () {
        final json = Map<String, dynamic>.from(garmentJson)..remove('thumbnailUrl');
        final model = OutfitGarmentModel.fromJson(json);
        expect(model.thumbnailUrl, isNull);
      });

    });

    group('toJson', () {
      test('serializes all fields', () {
        final model = OutfitGarmentModel.fromJson(garmentJson);
        final json = model.toJson();
        expect(json['garmentId'], 'g-001');
        expect(json['thumbnailUrl'], 'https://cdn.example.com/g001.jpg');
        expect(json['type'], 'top');
        expect(json['color'], 'white');
        expect(json['style'], 'casual');
      });

      test('round-trips correctly', () {
        final model = OutfitGarmentModel.fromJson(garmentJson);
        final restored = OutfitGarmentModel.fromJson(model.toJson());
        expect(restored.garmentId, model.garmentId);
        expect(restored.type, model.type);
        expect(restored.color, model.color);
      });
    });
  });

  group('OutfitModel', () {
    group('fromJson', () {
      test('parses a fully populated outfit JSON', () {
        final model = OutfitModel.fromJson(fullOutfitJson);
        expect(model.id, 'outfit-xyz');
        expect(model.name, 'Summer Casual');
        expect(model.garments.length, 1);
        expect(model.mood, 'relaxed');
        expect(model.event, 'weekend');
        expect(model.weatherContext, 'sunny 28°C');
        expect(model.score, closeTo(0.87, 0.001));
        expect(model.rationale, 'Great match for warm weather');
        expect(model.isFavorite, isTrue);
        expect(model.wornAt, wornDate);
        expect(model.createdAt, fixedDate);
      });

      test('parses garments list as OutfitGarmentModel instances', () {
        final model = OutfitModel.fromJson(fullOutfitJson);
        expect(model.garments.first, isA<OutfitGarmentModel>());
        expect(model.garments.first.garmentId, 'g-001');
      });

      test('parses empty garments list', () {
        final json = Map<String, dynamic>.from(fullOutfitJson);
        json['garments'] = [];
        final model = OutfitModel.fromJson(json);
        expect(model.garments, isEmpty);
      });

      test('defaults garments to empty list when absent', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)..remove('garments');
        final model = OutfitModel.fromJson(json);
        expect(model.garments, isEmpty);
      });

      test('defaults isFavorite to false when missing', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)..remove('isFavorite');
        expect(OutfitModel.fromJson(json).isFavorite, isFalse);
      });

      test('sets wornAt to null when absent', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)..remove('wornAt');
        expect(OutfitModel.fromJson(json).wornAt, isNull);
      });

      test('sets optional string fields to null when absent', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)
          ..remove('mood')
          ..remove('event')
          ..remove('weatherContext')
          ..remove('rationale');
        final model = OutfitModel.fromJson(json);
        expect(model.mood, isNull);
        expect(model.event, isNull);
        expect(model.weatherContext, isNull);
        expect(model.rationale, isNull);
      });

      test('parses score from integer value', () {
        final json = Map<String, dynamic>.from(fullOutfitJson);
        json['score'] = 1;
        final model = OutfitModel.fromJson(json);
        expect(model.score, 1.0);
        expect(model.score, isA<double>());
      });

      test('sets score to null when absent', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)..remove('score');
        expect(OutfitModel.fromJson(json).score, isNull);
      });
    });

    group('toJson', () {
      late OutfitModel model;

      setUp(() {
        model = OutfitModel.fromJson(fullOutfitJson);
      });

      test('serializes all fields', () {
        final json = model.toJson();
        expect(json['id'], 'outfit-xyz');
        expect(json['name'], 'Summer Casual');
        expect(json['garments'], isA<List>());
        expect((json['garments'] as List).length, 1);
        expect(json['mood'], 'relaxed');
        expect(json['event'], 'weekend');
        expect(json['weatherContext'], 'sunny 28°C');
        expect(json['score'], closeTo(0.87, 0.001));
        expect(json['rationale'], 'Great match for warm weather');
        expect(json['isFavorite'], isTrue);
        expect(json['wornAt'], wornDate.toIso8601String());
        expect(json['createdAt'], fixedDate.toIso8601String());
      });

      test('serializes null wornAt', () {
        final json = Map<String, dynamic>.from(fullOutfitJson)..remove('wornAt');
        final noWorn = OutfitModel.fromJson(json);
        expect(noWorn.toJson()['wornAt'], isNull);
      });

      test('round-trips correctly through fromJson/toJson', () {
        // Go through jsonEncode/jsonDecode to properly serialize nested objects,
        // matching how Outfit.toJson is used in production (via jsonEncode).
        final json =
            jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>;
        final restored = OutfitModel.fromJson(json);
        expect(restored.id, model.id);
        expect(restored.name, model.name);
        expect(restored.isFavorite, model.isFavorite);
        expect(restored.garments.length, model.garments.length);
        expect(restored.garments.first.garmentId,
            model.garments.first.garmentId);
      });
    });

    group('inheritance', () {
      test('OutfitModel is a subtype of Outfit', () {
        expect(OutfitModel.fromJson(fullOutfitJson), isA<Outfit>());
      });
    });
  });
}
