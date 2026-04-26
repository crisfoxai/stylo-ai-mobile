import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/features/subscription/domain/entities/subscription.dart';
import 'package:stylo_ai/features/subscription/data/models/subscription_model.dart';

void main() {
  group('SubscriptionPlan enum', () {
    test('has four values', () {
      expect(SubscriptionPlan.values.length, 4);
    });

    test('contains expected values', () {
      expect(SubscriptionPlan.values, containsAll([
        SubscriptionPlan.free,
        SubscriptionPlan.stylist,
        SubscriptionPlan.pro,
        SubscriptionPlan.proUnlimited,
      ]));
    });
  });

  group('SubscriptionStatus enum', () {
    test('has five values', () {
      expect(SubscriptionStatus.values.length, 5);
    });

    test('contains expected values', () {
      expect(SubscriptionStatus.values, containsAll([
        SubscriptionStatus.active,
        SubscriptionStatus.free,
        SubscriptionStatus.grace,
        SubscriptionStatus.expired,
        SubscriptionStatus.cancelled,
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

      test('returns true when status is grace', () {
        expect(makeSub(status: SubscriptionStatus.grace).isActive, isTrue);
      });

      test('returns false when status is expired', () {
        expect(makeSub(status: SubscriptionStatus.expired).isActive, isFalse);
      });

      test('returns false when status is cancelled', () {
        expect(makeSub(status: SubscriptionStatus.cancelled).isActive, isFalse);
      });
    });

    group('isPremium getter', () {
      test('returns true for active pro subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
        );
        expect(sub.isPremium, isTrue);
      });

      test('returns true for grace pro subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.grace,
        );
        expect(sub.isPremium, isTrue);
      });

      test('returns false for free plan regardless of status', () {
        expect(
          makeSub(plan: SubscriptionPlan.free, status: SubscriptionStatus.active).isPremium,
          isFalse,
        );
      });

      test('returns false for expired pro subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.expired,
        );
        expect(sub.isPremium, isFalse);
      });

      test('returns false for cancelled pro subscription', () {
        final sub = makeSub(
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.cancelled,
        );
        expect(sub.isPremium, isFalse);
      });
    });

    group('hasTryon getter', () {
      test('returns true for active pro subscription', () {
        expect(makeSub(plan: SubscriptionPlan.pro).hasTryon, isTrue);
      });

      test('returns true for active proUnlimited subscription', () {
        expect(makeSub(plan: SubscriptionPlan.proUnlimited).hasTryon, isTrue);
      });

      test('returns false for stylist plan', () {
        expect(makeSub(plan: SubscriptionPlan.stylist).hasTryon, isFalse);
      });

      test('returns false for free plan', () {
        expect(makeSub(plan: SubscriptionPlan.free).hasTryon, isFalse);
      });
    });

    group('hasChat getter', () {
      test('returns true for active stylist subscription', () {
        expect(makeSub(plan: SubscriptionPlan.stylist).hasChat, isTrue);
      });

      test('returns true for active pro subscription', () {
        expect(makeSub(plan: SubscriptionPlan.pro).hasChat, isTrue);
      });

      test('returns false for free plan', () {
        expect(makeSub(plan: SubscriptionPlan.free).hasChat, isFalse);
      });
    });

    group('tryonLimit getter', () {
      test('returns 20 for pro', () {
        expect(makeSub(plan: SubscriptionPlan.pro).tryonLimit, 20);
      });

      test('returns 80 for proUnlimited', () {
        expect(makeSub(plan: SubscriptionPlan.proUnlimited).tryonLimit, 80);
      });

      test('returns 0 for free and stylist', () {
        expect(makeSub(plan: SubscriptionPlan.free).tryonLimit, 0);
        expect(makeSub(plan: SubscriptionPlan.stylist).tryonLimit, 0);
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
          isNot(equals(makeSub(plan: SubscriptionPlan.pro))),
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
      'plan': 'pro',
      'status': 'active',
      'expiresAt': '2025-12-31T00:00:00.000Z',
    };

    group('fromJson', () {
      test('parses a fully populated JSON object', () {
        final model = SubscriptionModel.fromJson(fullJson);
        expect(model.id, 'sub-abc');
        expect(model.plan, SubscriptionPlan.pro);
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
          'grace': SubscriptionStatus.grace,
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
        expect(json['plan'], 'pro');
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
