import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/auth/data/models/user_model.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    final testDate = DateTime.parse('2024-01-15T10:30:00.000Z');

    final fullJson = {
      'id': 'user-abc',
      'email': 'test@stylo.ai',
      'firstName': 'María',
      'lastName': 'Pérez',
      'avatarUrl': 'https://example.com/avatar.jpg',
      'hasStyleProfile': true,
      'createdAt': '2024-01-15T10:30:00.000Z',
    };

    group('fromJson', () {
      test('parses a fully populated JSON object correctly', () {
        final model = UserModel.fromJson(fullJson);
        expect(model.id, 'user-abc');
        expect(model.email, 'test@stylo.ai');
        expect(model.firstName, 'María');
        expect(model.lastName, 'Pérez');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.hasStyleProfile, isTrue);
        expect(model.createdAt, testDate);
      });

      test('defaults hasStyleProfile to false when missing', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('hasStyleProfile');
        final model = UserModel.fromJson(json);
        expect(model.hasStyleProfile, isFalse);
      });

      test('sets avatarUrl to null when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('avatarUrl');
        final model = UserModel.fromJson(json);
        expect(model.avatarUrl, isNull);
      });

      test('sets avatarUrl to null when explicitly null in JSON', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['avatarUrl'] = null;
        final model = UserModel.fromJson(json);
        expect(model.avatarUrl, isNull);
      });

      test('parses createdAt as UTC DateTime', () {
        final model = UserModel.fromJson(fullJson);
        expect(model.createdAt.isAtSameMomentAs(testDate), isTrue);
      });

      test('throws when id is missing from JSON', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('id');
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });

      test('throws when email is missing from JSON', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('email');
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });

      test('throws when createdAt is missing from JSON', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('createdAt');
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });

      test('throws on invalid createdAt date string', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['createdAt'] = 'not-a-date';
        expect(() => UserModel.fromJson(json), throwsA(anything));
      });
    });

    group('toJson', () {
      final model = UserModel(
        id: 'user-abc',
        email: 'test@stylo.ai',
        firstName: 'María',
        lastName: 'Pérez',
        avatarUrl: 'https://example.com/avatar.jpg',
        hasStyleProfile: true,
        createdAt: testDate,
      );

      test('serializes all fields', () {
        final json = model.toJson();
        expect(json['id'], 'user-abc');
        expect(json['email'], 'test@stylo.ai');
        expect(json['firstName'], 'María');
        expect(json['lastName'], 'Pérez');
        expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(json['hasStyleProfile'], isTrue);
        expect(json['createdAt'], testDate.toIso8601String());
      });

      test('serializes null avatarUrl', () {
        final modelNoAvatar = UserModel(
          id: 'user-abc',
          email: 'test@stylo.ai',
          firstName: 'María',
          lastName: 'Pérez',
          hasStyleProfile: false,
          createdAt: testDate,
        );
        final json = modelNoAvatar.toJson();
        expect(json.containsKey('avatarUrl'), isTrue);
        expect(json['avatarUrl'], isNull);
      });

      test('round-trips through fromJson/toJson without data loss', () {
        final json = model.toJson();
        final restored = UserModel.fromJson(json);
        expect(restored.id, model.id);
        expect(restored.email, model.email);
        expect(restored.firstName, model.firstName);
        expect(restored.lastName, model.lastName);
        expect(restored.avatarUrl, model.avatarUrl);
        expect(restored.hasStyleProfile, model.hasStyleProfile);
        expect(restored.createdAt.toIso8601String(), model.createdAt.toIso8601String());
      });
    });

    group('inheritance', () {
      test('UserModel is a subtype of User', () {
        final model = UserModel.fromJson(fullJson);
        expect(model, isA<User>());
      });

      test('fullName and initials getters work on UserModel', () {
        final model = UserModel.fromJson(fullJson);
        expect(model.fullName, 'María Pérez');
        expect(model.initials, 'MP');
      });
    });
  });
}
