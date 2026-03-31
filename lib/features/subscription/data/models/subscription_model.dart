import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.plan,
    required super.status,
    super.expiresAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      plan: _parsePlan(json['plan'] as String? ?? 'free'),
      status: _parseStatus(json['status'] as String? ?? 'active'),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan': plan.name,
        'status': status.name,
        'expiresAt': expiresAt?.toIso8601String(),
      };

  static SubscriptionPlan _parsePlan(String value) {
    switch (value.toLowerCase()) {
      case 'premium':
        return SubscriptionPlan.premium;
      default:
        return SubscriptionPlan.free;
    }
  }

  static SubscriptionStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'trialing':
        return SubscriptionStatus.trialing;
      default:
        return SubscriptionStatus.active;
    }
  }
}
