import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/stylo_button.dart';

class VirtualTryOnScreen extends ConsumerWidget {
  const VirtualTryOnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Prueba Virtual',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                _TryOnIllustration(),

                const SizedBox(height: AppSpacing.xxxl),

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        PhosphorIconsFill.sparkle,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'En desarrollo',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Próximamente',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Pronto podrás probarte virtualmente cualquier prenda de tu guardarropa usando inteligencia artificial.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Combina outfits, visualiza cómo te queda cada prenda y descubre tu estilo antes de vestirte.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Feature bullets
                _FeatureBullet(
                  icon: PhosphorIconsRegular.camera,
                  text: 'Foto tuya como base virtual',
                ),
                const SizedBox(height: AppSpacing.md),
                _FeatureBullet(
                  icon: PhosphorIconsRegular.tShirt,
                  text: 'Combina prendas de tu guardarropa',
                ),
                const SizedBox(height: AppSpacing.md),
                _FeatureBullet(
                  icon: PhosphorIconsRegular.sparkle,
                  text: 'Sugerencias de outfits con IA',
                ),

                const SizedBox(height: AppSpacing.xxxxl),

                StyloButton(
                  label: 'Avisarme cuando esté disponible',
                  variant: StyloButtonVariant.outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Te avisaremos cuando esté listo.',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TryOnIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          // Icon
          Icon(
            PhosphorIconsRegular.tShirt,
            size: 80,
            color: AppColors.accent,
          ),
          // Sparkle decorations
          Positioned(
            top: 20,
            right: 24,
            child: Icon(
              PhosphorIconsFill.sparkle,
              size: 20,
              color: AppColors.accent.withOpacity(0.6),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 20,
            child: Icon(
              PhosphorIconsFill.sparkle,
              size: 14,
              color: AppColors.accent.withOpacity(0.4),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Icon(
              PhosphorIconsFill.star,
              size: 12,
              color: AppColors.accentLight.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentSubtle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
