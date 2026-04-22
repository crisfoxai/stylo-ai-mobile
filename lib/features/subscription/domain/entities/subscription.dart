import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum SubscriptionPlan { free, premium }

enum SubscriptionStatus { active, expired, cancelled, trialing }

@freezed
class Subscription with _$Subscription {
  const Subscription._();

  const factory Subscription({
    required String id,
    required SubscriptionPlan plan,
    required SubscriptionStatus status,
    String? platform,
    DateTime? expiresAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  bool get isPremium => plan == SubscriptionPlan.premium && isActive;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
