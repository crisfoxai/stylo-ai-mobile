import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Brand colors', () {
      test('primary is #1A1A1A', () {
        expect(AppColors.primary, const Color(0xFF1A1A1A));
      });

      test('primaryLight is #2D2D2D', () {
        expect(AppColors.primaryLight, const Color(0xFF2D2D2D));
      });

      test('accent is #C67A5C', () {
        expect(AppColors.accent, const Color(0xFFC67A5C));
      });

      test('accentLight is #D4967E', () {
        expect(AppColors.accentLight, const Color(0xFFD4967E));
      });

      test('accentSubtle is #FAF0EB', () {
        expect(AppColors.accentSubtle, const Color(0xFFFAF0EB));
      });
    });

    group('Background & Surface colors', () {
      test('background is #FAFAFA', () {
        expect(AppColors.background, const Color(0xFFFAFAFA));
      });

      test('surface is #FFFFFF', () {
        expect(AppColors.surface, const Color(0xFFFFFFFF));
      });

      test('surfaceElevated is #FFFFFF', () {
        expect(AppColors.surfaceElevated, const Color(0xFFFFFFFF));
      });
    });

    group('Text colors', () {
      test('textPrimary is #1A1A1A', () {
        expect(AppColors.textPrimary, const Color(0xFF1A1A1A));
      });

      test('textSecondary is #6B6B6B', () {
        expect(AppColors.textSecondary, const Color(0xFF6B6B6B));
      });

      test('textTertiary is #9E9E9E', () {
        expect(AppColors.textTertiary, const Color(0xFF9E9E9E));
      });

      test('textOnPrimary is #FFFFFF', () {
        expect(AppColors.textOnPrimary, const Color(0xFFFFFFFF));
      });

      test('textOnSecondary is #FFFFFF', () {
        expect(AppColors.textOnSecondary, const Color(0xFFFFFFFF));
      });

      test('textDisabled is #B5B0AD', () {
        expect(AppColors.textDisabled, const Color(0xFFB5B0AD));
      });
    });

    group('Borders & Dividers colors', () {
      test('border is #E8E8E8', () {
        expect(AppColors.border, const Color(0xFFE8E8E8));
      });

      test('borderLight is #F0F0F0', () {
        expect(AppColors.borderLight, const Color(0xFFF0F0F0));
      });

      test('divider is #F2F2F2', () {
        expect(AppColors.divider, const Color(0xFFF2F2F2));
      });
    });

    group('Semantic colors', () {
      test('success is #4CAF50', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
      });

      test('warning is #FFB74D', () {
        expect(AppColors.warning, const Color(0xFFFFB74D));
      });

      test('error is #EF5350', () {
        expect(AppColors.error, const Color(0xFFEF5350));
      });

      test('info is #42A5F5', () {
        expect(AppColors.info, const Color(0xFF42A5F5));
      });
    });

    group('Misc colors', () {
      test('shimmer is #F5F5F5', () {
        expect(AppColors.shimmer, const Color(0xFFF5F5F5));
      });

      test('overlay is 50% opaque black', () {
        expect(AppColors.overlay, const Color(0x80000000));
      });
    });

    group('Dark theme colors', () {
      test('darkBackground is #121212', () {
        expect(AppColors.darkBackground, const Color(0xFF121212));
      });

      test('darkSurface is #1E1E1E', () {
        expect(AppColors.darkSurface, const Color(0xFF1E1E1E));
      });

      test('darkBorder is #2C2C2C', () {
        expect(AppColors.darkBorder, const Color(0xFF2C2C2C));
      });
    });

    group('Color opacity values', () {
      test('all fully opaque colors have alpha 0xFF', () {
        const fullyOpaque = [
          AppColors.primary,
          AppColors.accent,
          AppColors.background,
          AppColors.surface,
          AppColors.textPrimary,
          AppColors.error,
          AppColors.success,
        ];
        for (final color in fullyOpaque) {
          expect(color.alpha, 0xFF,
              reason: 'Color $color should have full opacity');
        }
      });

      test('overlay has 50% opacity', () {
        expect(AppColors.overlay.alpha, 0x80);
      });
    });
  });
}
