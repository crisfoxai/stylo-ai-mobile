import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_spacing.dart';

void main() {
  group('AppSpacing', () {
    test('xs equals 4.0', () {
      expect(AppSpacing.xs, 4.0);
    });

    test('sm equals 8.0', () {
      expect(AppSpacing.sm, 8.0);
    });

    test('md equals 12.0', () {
      expect(AppSpacing.md, 12.0);
    });

    test('lg equals 16.0', () {
      expect(AppSpacing.lg, 16.0);
    });

    test('xl equals 20.0', () {
      expect(AppSpacing.xl, 20.0);
    });

    test('xxl equals 24.0', () {
      expect(AppSpacing.xxl, 24.0);
    });

    test('xxxl equals 32.0', () {
      expect(AppSpacing.xxxl, 32.0);
    });

    test('xxxxl equals 48.0', () {
      expect(AppSpacing.xxxxl, 48.0);
    });

    test('spacing values are in ascending order', () {
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
      expect(AppSpacing.xxl, lessThan(AppSpacing.xxxl));
      expect(AppSpacing.xxxl, lessThan(AppSpacing.xxxxl));
    });

    test('all spacing values are positive', () {
      final spacings = [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
        AppSpacing.xxxxl,
      ];
      for (final spacing in spacings) {
        expect(spacing, greaterThan(0));
      }
    });
  });

  group('AppRadius', () {
    test('sm equals 8.0', () {
      expect(AppRadius.sm, 8.0);
    });

    test('md equals 12.0', () {
      expect(AppRadius.md, 12.0);
    });

    test('lg equals 16.0', () {
      expect(AppRadius.lg, 16.0);
    });

    test('xl equals 24.0', () {
      expect(AppRadius.xl, 24.0);
    });

    test('full equals 100.0', () {
      expect(AppRadius.full, 100.0);
    });

    test('radius values are in ascending order', () {
      expect(AppRadius.sm, lessThan(AppRadius.md));
      expect(AppRadius.md, lessThan(AppRadius.lg));
      expect(AppRadius.lg, lessThan(AppRadius.xl));
      expect(AppRadius.xl, lessThan(AppRadius.full));
    });

    test('all radius values are positive', () {
      final radii = [
        AppRadius.sm,
        AppRadius.md,
        AppRadius.lg,
        AppRadius.xl,
        AppRadius.full,
      ];
      for (final radius in radii) {
        expect(radius, greaterThan(0));
      }
    });

    test('full radius is suitable for pill shapes', () {
      expect(AppRadius.full, greaterThanOrEqualTo(50.0));
    });
  });
}
