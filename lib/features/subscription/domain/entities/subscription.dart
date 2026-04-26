import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum SubscriptionPlan { free, stylist, pro, proUnlimited }

enum SubscriptionStatus { active, free, grace, expired, cancelled }

@freezed
class Subscription with _$Subscription {
  const Subscription._();

  const factory Subscription({
    required String id,
    @Default(SubscriptionPlan.free) SubscriptionPlan plan,
    @Default(SubscriptionStatus.free) SubscriptionStatus status,
    String? platform,
    String? productId,
    DateTime? expiresAt,
    @Default(0) int tryonUsedThisMonth,
    @Default(0) int chatMessagesUsedThisMonth,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  bool get isActive =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.grace;

  bool get isFree => plan == SubscriptionPlan.free || !isActive;

  bool get isPremium => plan != SubscriptionPlan.free && isActive;

  bool get hasTryon =>
      (plan == SubscriptionPlan.pro || plan == SubscriptionPlan.proUnlimited) &&
      isActive;

  bool get hasChat => plan != SubscriptionPlan.free && isActive;

  bool get hasUnlimitedChat =>
      (plan == SubscriptionPlan.pro || plan == SubscriptionPlan.proUnlimited) &&
      isActive;

  int get tryonLimit => switch (plan) {
        SubscriptionPlan.pro => 20,
        SubscriptionPlan.proUnlimited => 80,
        _ => 0,
      };
}
