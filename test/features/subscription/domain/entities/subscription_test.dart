import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/subscription/domain/entities/subscription.dart';
import 'package:stylo_ai/features/subscription/data/models/subscription_model.dart';

void main() {
  group('SubscriptionPlan enum', () {
    test('has two values', () {
      expect(SubscriptionPlan.values.length, 2);
    });

    test('contains free and premium', () {
      expect(SubscriptionPlan.values, containsAll([
        SubscriptionPlan.free,
        SubscriptionPlan.premium,
      ]));
    });
  });

  group('SubscriptionStatus enum', () {
    test('has four values', () {
      expect(SubscriptionStatus.values.length, 4);
    });

    test('contains expected values', () {
      expect(SubscriptionStatus.values, containsAll([
        SubscriptionStatus.active,
        SubscriptionStatus.expired,
        SubscriptionStatus.cancelled,
        SubscriptionStatus.trialing,
      ]));
    });
  });

  group('Subscription', () {
    Subscription makeSub({
      String id = 'sub-1',
      SubscriptionPlan plan = SubscriptionPlan.free,
      SubscriptionStatus status = SubscriptionStatus.active,
      DateTime? expiresAt,
    }) {
      return Subscription(
        id: id,
        plan: plan,
        status: status,
        expiresAt: expiresAt,
      );
    }

    group('construction', () {
      test('creates with required fields', () {
        final sub = makeSub();
        expect(sub.id, 'sub-1');
        expect(sub.plan, SubscriptionPlan.free);
        expect(sub.status, SubscriptionStatus.active);
        expect(sub.expiresAt, isNull);
      });

      test('stores expiresAt when provided', () {
        final expiry = DateTime(2025, 12, 31);
        final sub = makeSub(expiresAt: expiry);
        expect(sub.expiresAt, expiry);
      });
    });

    group('isActive getter', () {
      test('returns true when status is active', () {
        expect(makeSub(status: SubscriptionStatus.active).isActive, isTrue);
      });

      test('returns true when status is trialing', () {
        expect(makeSub(status: SubscriptionStatus.trialing).isActive, isTrue);
      });

      test('returns false when status is expired', () {
        expect(makeSub(status: SubscriptionStatus.expired).isActive, isFalse);
      });

      test('returns false when status is cancelled', () {
        expect(makeSub(status: SubscriptionStatus.cancelled).isActive, isFalse);
      });
    });

    group('isPremium getter', () {
      test('returns true for active premium subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.active,
        );
        expect(sub.isPremium, isTrue);
      });

      test('returns true for trialing premium subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.trialing,
        );
        expect(sub.isPremium, isTrue);
      });

      test('returns false for free plan regardless of status', () {
        expect(
          makeSub(plan: SubscriptionPlan.free, status: SubscriptionStatus.active).isPremium,
          isFalse,
        );
      });

      test('returns false for expired premium subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.expired,
        );
        expect(sub.isPremium, isFalse);
      });

      test('returns false for cancelled premium subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.cancelled,
        );
        expect(sub.isPremium, isFalse);
      });
    });

    group('isExpired getter', () {
      test('returns false when expiresAt is null', () {
        expect(makeSub().isExpired, isFalse);
      });

      test('returns true when expiresAt is in the past', () {
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        expect(makeSub(expiresAt: pastDate).isExpired, isTrue);
      });

      test('returns false when expiresAt is in the future', () {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        expect(makeSub(expiresAt: futureDate).isExpired, isFalse);
      });
    });

    group('Equatable equality', () {
      test('two subscriptions with same props are equal', () {
        expect(makeSub(), equals(makeSub()));
      });

      test('subscriptions with different ids are not equal', () {
        expect(makeSub(id: 's1'), isNot(equals(makeSub(id: 's2'))));
      });

      test('subscriptions with different plans are not equal', () {
        expect(
          makeSub(plan: SubscriptionPlan.free),
          isNot(equals(makeSub(plan: SubscriptionPlan.premium))),
        );
      });

      test('subscriptions with different statuses are not equal', () {
        expect(
          makeSub(status: SubscriptionStatus.active),
          isNot(equals(makeSub(status: SubscriptionStatus.expired))),
        );
      });

    });
  });

  group('SubscriptionModel', () {
    final fullJson = {
      'id': 'sub-abc',
      'plan': 'premium',
      'status': 'active',
      'expiresAt': '2025-12-31T00:00:00.000Z',
    };

    group('fromJson', () {
      test('parses a fully populated JSON object', () {
        final model = SubscriptionModel.fromJson(fullJson);
        expect(model.id, 'sub-abc');
        expect(model.plan, SubscriptionPlan.premium);
        expect(model.status, SubscriptionStatus.active);
        expect(model.expiresAt, isNotNull);
      });

      test('parses free plan', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['plan'] = 'free';
        expect(SubscriptionModel.fromJson(json).plan, SubscriptionPlan.free);
      });

      test('parses all valid status values', () {
        for (final entry in {
          'active': SubscriptionStatus.active,
          'expired': SubscriptionStatus.expired,
          'cancelled': SubscriptionStatus.cancelled,
          'trialing': SubscriptionStatus.trialing,
        }.entries) {
          final json = Map<String, dynamic>.from(fullJson);
          json['status'] = entry.key;
          expect(SubscriptionModel.fromJson(json).status, entry.value);
        }
      });

      test('sets expiresAt to null when absent', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('expiresAt');
        expect(SubscriptionModel.fromJson(json).expiresAt, isNull);
      });

      test('sets expiresAt to null when explicitly null', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['expiresAt'] = null;
        expect(SubscriptionModel.fromJson(json).expiresAt, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final model = SubscriptionModel.fromJson(fullJson);
        final json = model.toJson();
        expect(json['id'], 'sub-abc');
        expect(json['plan'], 'premium');
        expect(json['status'], 'active');
        expect(json['expiresAt'], isNotNull);
      });

      test('serializes null expiresAt', () {
        final json = Map<String, dynamic>.from(fullJson)..remove('expiresAt');
        final model = SubscriptionModel.fromJson(json);
        expect(model.toJson()['expiresAt'], isNull);
      });

      test('round-trips correctly', () {
        final model = SubscriptionModel.fromJson(fullJson);
        final restored = SubscriptionModel.fromJson(model.toJson());
        expect(restored.id, model.id);
        expect(restored.plan, model.plan);
        expect(restored.status, model.status);
      });
    });

    group('inheritance', () {
      test('SubscriptionModel is a subtype of Subscription', () {
        expect(SubscriptionModel.fromJson(fullJson), isA<Subscription>());
      });
    });
  });
}
