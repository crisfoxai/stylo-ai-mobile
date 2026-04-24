import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    User makeUser({
      String id = 'user-1',
      String email = 'ana@example.com',
      String firstName = 'Ana',
      String lastName = 'García',
      String? avatarUrl,
      bool hasStyleProfile = false,
      DateTime? createdAt,
    }) {
      return User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
        hasStyleProfile: hasStyleProfile,
        createdAt: createdAt ?? testDate,
      );
    }

    group('construction', () {
      test('creates a User with all required fields', () {
        final user = makeUser();
        expect(user.id, 'user-1');
        expect(user.email, 'ana@example.com');
        expect(user.firstName, 'Ana');
        expect(user.lastName, 'García');
        expect(user.avatarUrl, isNull);
        expect(user.hasStyleProfile, isFalse);
        expect(user.createdAt, testDate);
      });

      test('creates a User with optional fields set', () {
        final user = makeUser(
          avatarUrl: 'https://example.com/avatar.jpg',
          hasStyleProfile: true,
        );
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.hasStyleProfile, isTrue);
      });

      test('hasStyleProfile defaults to false', () {
        final user = makeUser();
        expect(user.hasStyleProfile, isFalse);
      });
    });

    group('fullName getter', () {
      test('returns first and last name separated by a space', () {
        final user = makeUser(firstName: 'Ana', lastName: 'García');
        expect(user.fullName, 'Ana García');
      });

      test('handles single-word names correctly', () {
        final user = makeUser(firstName: 'Cher', lastName: '');
        expect(user.fullName, 'Cher ');
      });

      test('handles empty first name', () {
        final user = makeUser(firstName: '', lastName: 'Smith');
        expect(user.fullName, ' Smith');
      });
    });

    group('initials getter', () {
      test('returns uppercased first characters of first and last name', () {
        final user = makeUser(firstName: 'Ana', lastName: 'García');
        expect(user.initials, 'AG');
      });

      test('returns empty string when both names are empty', () {
        final user = makeUser(firstName: '', lastName: '');
        expect(user.initials, '');
      });

      test('returns only first initial when last name is empty', () {
        final user = makeUser(firstName: 'Carlos', lastName: '');
        expect(user.initials, 'C');
      });

      test('returns only last initial when first name is empty', () {
        final user = makeUser(firstName: '', lastName: 'López');
        expect(user.initials, 'L');
      });

      test('always returns uppercase initials', () {
        final user = makeUser(firstName: 'maría', lastName: 'jose');
        expect(user.initials, 'MJ');
      });
    });

    group('Equatable equality', () {
      test('two users with same props are equal', () {
        final user1 = makeUser();
        final user2 = makeUser();
        expect(user1, equals(user2));
      });

      test('two users with different ids are not equal', () {
        final user1 = makeUser(id: 'user-1');
        final user2 = makeUser(id: 'user-2');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different emails are not equal', () {
        final user1 = makeUser(email: 'a@example.com');
        final user2 = makeUser(email: 'b@example.com');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different hasStyleProfile are not equal', () {
        final user1 = makeUser(hasStyleProfile: false);
        final user2 = makeUser(hasStyleProfile: true);
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different avatarUrls are not equal', () {
        final user1 = makeUser(avatarUrl: null);
        final user2 = makeUser(avatarUrl: 'https://example.com/avatar.jpg');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with same avatarUrl are equal', () {
        final user1 = makeUser(avatarUrl: 'https://example.com/avatar.jpg');
        final user2 = makeUser(avatarUrl: 'https://example.com/avatar.jpg');
        expect(user1, equals(user2));
      });
    });

  });
}
