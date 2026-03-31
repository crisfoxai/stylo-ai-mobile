import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/style_profile/domain/entities/style_profile.dart';

void main() {
  final now = DateTime(2024, 2, 14);

  StyleProfile makeProfile({
    String id = 'profile-1',
    List<String> aesthetics = const ['minimalist', 'casual'],
    List<String> favoriteColors = const ['black', 'white'],
    List<String> occasions = const ['work', 'weekend'],
    String adventureLevel = 'medium',
    List<String> priorities = const ['comfort', 'style'],
    String? styleBadge,
    DateTime? createdAt,
  }) {
    return StyleProfile(
      id: id,
      aesthetics: aesthetics,
      favoriteColors: favoriteColors,
      occasions: occasions,
      adventureLevel: adventureLevel,
      priorities: priorities,
      styleBadge: styleBadge,
      createdAt: createdAt ?? now,
    );
  }

  group('StyleProfile', () {
    group('construction', () {
      test('creates a StyleProfile with all required fields', () {
        final profile = makeProfile();
        expect(profile.id, 'profile-1');
        expect(profile.aesthetics, ['minimalist', 'casual']);
        expect(profile.favoriteColors, ['black', 'white']);
        expect(profile.occasions, ['work', 'weekend']);
        expect(profile.adventureLevel, 'medium');
        expect(profile.priorities, ['comfort', 'style']);
        expect(profile.styleBadge, isNull);
        expect(profile.createdAt, now);
      });

      test('stores styleBadge when provided', () {
        final profile = makeProfile(styleBadge: 'Classic Minimalist');
        expect(profile.styleBadge, 'Classic Minimalist');
      });

      test('accepts empty lists for collections', () {
        final profile = makeProfile(
          aesthetics: [],
          favoriteColors: [],
          occasions: [],
          priorities: [],
        );
        expect(profile.aesthetics, isEmpty);
        expect(profile.favoriteColors, isEmpty);
        expect(profile.occasions, isEmpty);
        expect(profile.priorities, isEmpty);
      });
    });

    group('Equatable equality', () {
      test('two profiles with same props are equal', () {
        expect(makeProfile(), equals(makeProfile()));
      });

      test('profiles with different ids are not equal', () {
        expect(
          makeProfile(id: 'p1'),
          isNot(equals(makeProfile(id: 'p2'))),
        );
      });

      test('profiles with different aesthetics are not equal', () {
        expect(
          makeProfile(aesthetics: ['minimalist']),
          isNot(equals(makeProfile(aesthetics: ['streetwear']))),
        );
      });

      test('profiles with different adventureLevels are not equal', () {
        expect(
          makeProfile(adventureLevel: 'low'),
          isNot(equals(makeProfile(adventureLevel: 'high'))),
        );
      });

      test('profiles with different styleBadges are not equal', () {
        expect(
          makeProfile(styleBadge: null),
          isNot(equals(makeProfile(styleBadge: 'Trendsetter'))),
        );
      });
    });

    group('props', () {
      test('props contains 7 entries', () {
        expect(makeProfile().props.length, 7);
      });

      test('props does not include createdAt', () {
        // Based on the entity definition, createdAt is NOT in props
        final profile = makeProfile();
        expect(profile.props.contains(profile.createdAt), isFalse);
      });

      test('props includes all list fields', () {
        final profile = makeProfile();
        expect(profile.props, containsAll([
          profile.id,
          profile.aesthetics,
          profile.favoriteColors,
          profile.occasions,
          profile.adventureLevel,
          profile.priorities,
          profile.styleBadge,
        ]));
      });
    });
  });
}
