import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_colors.dart';
import 'package:stylo_ai/shared/widgets/stylo_chip.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('StyloChip', () {
    group('basic rendering', () {
      testWidgets('renders label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Casual',
            isSelected: false,
          ),
        ));

        expect(find.text('Casual'), findsOneWidget);
      });

      testWidgets('renders without throwing when not selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Test Chip',
            isSelected: false,
          ),
        ));

        expect(find.byType(StyloChip), findsOneWidget);
      });

      testWidgets('renders without throwing when selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Test Chip',
            isSelected: true,
          ),
        ));

        expect(find.byType(StyloChip), findsOneWidget);
      });
    });

    group('selected state', () {
      testWidgets('uses accent color background when selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Selected',
            isSelected: true,
          ),
        ));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.accent);
      });

      testWidgets('uses surface color background when not selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Unselected',
            isSelected: false,
          ),
        ));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.surface);
      });

      testWidgets('border uses accent color when selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Selected',
            isSelected: true,
          ),
        ));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.top.color, AppColors.accent);
      });

      testWidgets('border uses border color when not selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Unselected',
            isSelected: false,
          ),
        ));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.top.color, AppColors.border);
      });
    });

    group('onTap callback', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(buildTestApp(
          StyloChip(
            label: 'Tap me',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        expect(tapped, isTrue);
      });

      testWidgets('does not throw when onTap is null and tapped', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'No Tap',
            isSelected: false,
            onTap: null,
          ),
        ));

        // Tapping should not throw
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
      });

      testWidgets('calls onTap when selected chip is tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(buildTestApp(
          StyloChip(
            label: 'Selected',
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ));

        await tester.tap(find.byType(GestureDetector));
        expect(tapped, isTrue);
      });
    });

    group('icon support', () {
      testWidgets('renders icon when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'With Icon',
            isSelected: false,
            icon: Icons.star,
          ),
        ));

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('With Icon'), findsOneWidget);
      });

      testWidgets('does not render icon widget when not provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'No Icon',
            isSelected: false,
          ),
        ));

        // No Icon widget should be present
        expect(find.byType(Icon), findsNothing);
        expect(find.text('No Icon'), findsOneWidget);
      });

      testWidgets('icon color is white when selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Selected',
            isSelected: true,
            icon: Icons.favorite,
          ),
        ));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, Colors.white);
      });

      testWidgets('icon color is textSecondary when not selected', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Unselected',
            isSelected: false,
            icon: Icons.favorite,
          ),
        ));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.color, AppColors.textSecondary);
      });
    });

    group('animation', () {
      testWidgets('uses AnimatedContainer for smooth transitions', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloChip(
            label: 'Animated',
            isSelected: false,
          ),
        ));

        expect(find.byType(AnimatedContainer), findsOneWidget);
      });
    });
  });
}
