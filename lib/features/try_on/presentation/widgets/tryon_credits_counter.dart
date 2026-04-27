import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/tryon_credits_provider.dart';

class TryonCreditsCounter extends ConsumerWidget {
  const TryonCreditsCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(tryonCreditsProvider);
    if (credits.isUnlimited) return const SizedBox.shrink();

    final color = credits.isEmpty
        ? AppColors.error
        : credits.isLow
            ? Colors.orange
            : AppColors.textSecondary;

    return Text(
      '${credits.remaining} try-ons restantes',
      style: AppTypography.bodySmall.copyWith(color: color),
    );
  }
}
