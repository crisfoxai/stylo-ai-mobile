import 'package:equatable/equatable.dart';

enum SubscriptionPlan { free, premium }

enum SubscriptionStatus { active, expired, cancelled, trialing }

class Subscription extends Equatable {
  final String id;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? expiresAt;

  const Subscription({
    required this.id,
    required this.plan,
    required this.status,
    this.expiresAt,
  });

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  bool get isPremium => plan == SubscriptionPlan.premium && isActive;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [id, plan, status, expiresAt];
}
