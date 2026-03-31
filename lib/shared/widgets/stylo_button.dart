import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum StyloButtonVariant { primary, outlined, destructive, text }

class StyloButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
  final StyloButtonVariant variant;
  final bool fullWidth;

  const StyloButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.variant = StyloButtonVariant.primary,
    this.fullWidth = true,
  });

  bool get _isDisabled => disabled || isLoading || onPressed == null;

  Color get _backgroundColor {
    if (_isDisabled && variant == StyloButtonVariant.primary) {
      return AppColors.textTertiary;
    }
    switch (variant) {
      case StyloButtonVariant.primary:
        return AppColors.primary;
      case StyloButtonVariant.outlined:
      case StyloButtonVariant.destructive:
      case StyloButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (_isDisabled) return AppColors.textTertiary;
    switch (variant) {
      case StyloButtonVariant.primary:
        return AppColors.textOnPrimary;
      case StyloButtonVariant.outlined:
        return AppColors.primary;
      case StyloButtonVariant.destructive:
        return AppColors.error;
      case StyloButtonVariant.text:
        return AppColors.accent;
    }
  }

  BorderSide get _borderSide {
    switch (variant) {
      case StyloButtonVariant.primary:
      case StyloButtonVariant.text:
        return BorderSide.none;
      case StyloButtonVariant.outlined:
        return BorderSide(
          color: _isDisabled ? AppColors.border : AppColors.border,
          width: 1.5,
        );
      case StyloButtonVariant.destructive:
        return BorderSide(
          color: _isDisabled ? AppColors.border : AppColors.error,
          width: 1.5,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: variant == StyloButtonVariant.text ? null : 52,
      child: OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          disabledForegroundColor: AppColors.textTertiary,
          disabledBackgroundColor: variant == StyloButtonVariant.primary
              ? AppColors.border
              : Colors.transparent,
          side: _borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: _isDisabled ? AppColors.textTertiary : _foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
