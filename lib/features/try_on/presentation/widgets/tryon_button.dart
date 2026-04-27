import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/tryon_credits_provider.dart';

class TryOnButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const TryOnButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTryon = ref.watch(hasTryonProvider);
    final credits = ref.watch(tryonCreditsProvider);

    if (!hasTryon) {
      return _LockedButton(
        onTap: () =>
            context.push('/paywall', extra: {'highlight': 'tryon'}),
      );
    }

    return _ActiveButton(
      onTap: onTap,
      credits: credits,
    );
  }
}

class _LockedButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LockedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('tryon_locked_btn'),
          onPressed: onTap,
          icon: const Icon(Icons.lock_outline, size: 18),
          label: const Text('Try-On Virtual'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.4)),
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full)),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Solo disponible en Pro · Ver planes →',
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.accent),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ActiveButton extends StatelessWidget {
  final VoidCallback? onTap;
  final TryonCredits credits;

  const _ActiveButton({this.onTap, required this.credits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          key: const Key('tryon_active_btn'),
          onPressed: onTap,
          icon: const Text('👗', style: TextStyle(fontSize: 16)),
          label: const Text('Try-On Virtual'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnPrimary,
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full)),
            elevation: 0,
          ),
        ),
        if (!credits.isUnlimited) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Te quedan ${credits.remaining} de ${credits.limit} try-ons este mes',
            style: AppTypography.bodySmall.copyWith(
              color: credits.isEmpty
                  ? AppColors.error
                  : credits.isLow
                      ? Colors.orange
                      : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
