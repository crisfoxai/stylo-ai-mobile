import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/style_profile/data/models/style_profile_model.dart';
import 'package:stylo_ai/features/style_profile/domain/entities/style_profile.dart';

void main() {
  final fixedDate = DateTime.parse('2024-02-14T00:00:00.000Z');

  final fullJson = <String, dynamic>{
    'id': 'profile-abc',
    'aesthetics': ['minimalist', 'casual', 'vintage'],
    'favoriteColors': ['black', 'beige', 'terracotta'],
    'occasions': ['work', 'brunch', 'weekend'],
    'adventureLevel': 'medium',
    'priorities': ['comfort', 'quality', 'sustainability'],
    'styleBadge': 'Classic Minimalist',
    'createdAt': '2024-02-14T00:00:00.000Z',
  };

  group('StyleProfileModel', () {
    group('fromJson', () {
      test('parses a fully populated JSON object', () {
        final model = StyleProfileModel.fromJson(fullJson);
        expect(model.id, 'profile-abc');
        expect(model.aesthetics, ['minimalist', 'casual', 'vintage']);
        expect(model.favoriteColors, ['black', 'beige', 'terracotta']);
        expect(model.occasions, ['work', 'brunch', 'weekend']);
        expect(model.adventureLevel, 'medium');
        expect(model.priorities, ['comfort', 'quality', 'sustainability']);
        expect(model.styleBadge, 'Classic Minimalist');
        expect(model.createdAt, fixedDate);
      });

      test('sets styleBadge to null when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('styleBadge');
        expect(StyleProfileModel.fromJson(json).styleBadge, isNull);
      });

      test('defaults adventureLevel to empty string when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('adventureLevel');
        expect(StyleProfileModel.fromJson(json).adventureLevel, '');
      });

      test('defaults priorities to empty list when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('priorities');
        expect(StyleProfileModel.fromJson(json).priorities, isEmpty);
      });

      test('parses empty aesthetics list', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['aesthetics'] = <String>[];
        expect(StyleProfileModel.fromJson(json).aesthetics, isEmpty);
      });

      test('parses empty favoriteColors list', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['favoriteColors'] = <String>[];
        expect(StyleProfileModel.fromJson(json).favoriteColors, isEmpty);
      });

      test('throws when id is missing', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('id');
        expect(() => StyleProfileModel.fromJson(json), throwsA(anything));
      });

      test('throws when createdAt is missing', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('createdAt');
        expect(() => StyleProfileModel.fromJson(json), throwsA(anything));
      });

      test('throws when aesthetics is missing', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('aesthetics');
        expect(() => StyleProfileModel.fromJson(json), throwsA(anything));
      });
    });

    group('toJson', () {
      test('serializes all expected fields', () {
        final model = StyleProfileModel.fromJson(fullJson);
        final json = model.toJson();
        // toJson() only includes the mutable profile fields (not id/createdAt/styleBadge)
        expect(json['aesthetics'], ['minimalist', 'casual', 'vintage']);
        expect(json['favoriteColors'], ['black', 'beige', 'terracotta']);
        expect(json['occasions'], ['work', 'brunch', 'weekend']);
        expect(json['adventureLevel'], 'medium');
        expect(json['priorities'], ['comfort', 'quality', 'sustainability']);
      });

      test('toJson does not include id', () {
        final model = StyleProfileModel.fromJson(fullJson);
        expect(model.toJson().containsKey('id'), isFalse);
      });

      test('toJson does not include createdAt', () {
        final model = StyleProfileModel.fromJson(fullJson);
        expect(model.toJson().containsKey('createdAt'), isFalse);
      });

      test('round-trips collection fields correctly', () {
        final model = StyleProfileModel.fromJson(fullJson);
        final json = model.toJson();
        // Use fromJson on the enriched form to verify round-trip
        final enriched = Map<String, dynamic>.from(json)
          ..['id'] = model.id
          ..['createdAt'] = fixedDate.toIso8601String()
          ..['styleBadge'] = model.styleBadge;
        final restored = StyleProfileModel.fromJson(enriched);
        expect(restored.aesthetics, model.aesthetics);
        expect(restored.favoriteColors, model.favoriteColors);
        expect(restored.priorities, model.priorities);
      });
    });

    group('inheritance', () {
      test('StyleProfileModel is a subtype of StyleProfile', () {
        expect(StyleProfileModel.fromJson(fullJson), isA<StyleProfile>());
      });
    });
  });
}
