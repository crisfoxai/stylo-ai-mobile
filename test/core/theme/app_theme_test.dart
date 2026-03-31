import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_colors.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('light theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.light;
      });

      test('light theme is created without throwing', () {
        expect(lightTheme, isNotNull);
      });

      test('light theme has correct brightness', () {
        expect(lightTheme.brightness, Brightness.light);
      });

      test('light theme uses Material 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('light theme scaffold background is AppColors.background', () {
        expect(lightTheme.scaffoldBackgroundColor, AppColors.background);
      });

      test('light color scheme primary is AppColors.primary', () {
        expect(lightTheme.colorScheme.primary, AppColors.primary);
      });

      test('light color scheme secondary is AppColors.accent', () {
        expect(lightTheme.colorScheme.secondary, AppColors.accent);
      });

      test('light color scheme surface is AppColors.surface', () {
        expect(lightTheme.colorScheme.surface, AppColors.surface);
      });

      test('light color scheme error is AppColors.error', () {
        expect(lightTheme.colorScheme.error, AppColors.error);
      });

      test('light color scheme onPrimary is AppColors.textOnPrimary', () {
        expect(lightTheme.colorScheme.onPrimary, AppColors.textOnPrimary);
      });

      test('light color scheme onSurface is AppColors.textPrimary', () {
        expect(lightTheme.colorScheme.onSurface, AppColors.textPrimary);
      });

      test('light theme has text theme defined', () {
        expect(lightTheme.textTheme, isNotNull);
        expect(lightTheme.textTheme.displayLarge, isNotNull);
        expect(lightTheme.textTheme.displayMedium, isNotNull);
        expect(lightTheme.textTheme.headlineLarge, isNotNull);
        expect(lightTheme.textTheme.headlineMedium, isNotNull);
        expect(lightTheme.textTheme.headlineSmall, isNotNull);
        expect(lightTheme.textTheme.titleLarge, isNotNull);
        expect(lightTheme.textTheme.titleMedium, isNotNull);
        expect(lightTheme.textTheme.bodyLarge, isNotNull);
        expect(lightTheme.textTheme.bodyMedium, isNotNull);
        expect(lightTheme.textTheme.bodySmall, isNotNull);
        expect(lightTheme.textTheme.labelLarge, isNotNull);
        expect(lightTheme.textTheme.labelMedium, isNotNull);
        expect(lightTheme.textTheme.labelSmall, isNotNull);
      });

      test('light theme app bar background is AppColors.background', () {
        expect(lightTheme.appBarTheme.backgroundColor, AppColors.background);
      });

      test('light theme app bar elevation is 0', () {
        expect(lightTheme.appBarTheme.elevation, 0);
      });

      test('light theme divider color is AppColors.divider', () {
        expect(lightTheme.dividerTheme.color, AppColors.divider);
      });

      test('light theme divider thickness is 1', () {
        expect(lightTheme.dividerTheme.thickness, 1);
      });

      test('light theme chip selected color is AppColors.accentSubtle', () {
        expect(lightTheme.chipTheme.selectedColor, AppColors.accentSubtle);
      });

      test('light theme bottom nav selected item color is AppColors.accent', () {
        expect(
          lightTheme.bottomNavigationBarTheme.selectedItemColor,
          AppColors.accent,
        );
      });

      test('light theme snack bar behavior is floating', () {
        expect(
          lightTheme.snackBarTheme.behavior,
          SnackBarBehavior.floating,
        );
      });
    });

    group('dark theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.dark;
      });

      test('dark theme is created without throwing', () {
        expect(darkTheme, isNotNull);
      });

      test('dark theme has correct brightness', () {
        expect(darkTheme.brightness, Brightness.dark);
      });

      test('dark theme scaffold background is AppColors.darkBackground', () {
        expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
      });

      test('dark color scheme primary is AppColors.accent', () {
        expect(darkTheme.colorScheme.primary, AppColors.accent);
      });

      test('dark color scheme secondary is AppColors.accentLight', () {
        expect(darkTheme.colorScheme.secondary, AppColors.accentLight);
      });

      test('dark color scheme surface is AppColors.darkSurface', () {
        expect(darkTheme.colorScheme.surface, AppColors.darkSurface);
      });

      test('dark color scheme error is AppColors.error', () {
        expect(darkTheme.colorScheme.error, AppColors.error);
      });

      test('dark theme app bar background is AppColors.darkBackground', () {
        expect(darkTheme.appBarTheme.backgroundColor, AppColors.darkBackground);
      });

      test('dark card theme color is AppColors.darkSurface', () {
        expect(darkTheme.cardTheme.color, AppColors.darkSurface);
      });
    });

    group('theme comparison', () {
      test('light and dark themes are different objects', () {
        expect(AppTheme.light, isNot(same(AppTheme.dark)));
      });

      test('light and dark themes have different brightness', () {
        expect(AppTheme.light.brightness, isNot(AppTheme.dark.brightness));
      });

      test('light and dark themes have different scaffold background colors', () {
        expect(
          AppTheme.light.scaffoldBackgroundColor,
          isNot(AppTheme.dark.scaffoldBackgroundColor),
        );
      });
    });
  });
}
