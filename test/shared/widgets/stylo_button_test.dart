import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/stylo_button.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('StyloButton', () {
    group('primary variant (default)', () {
      testWidgets('renders label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Submit',
            onPressed: () {},
          ),
        ));

        expect(find.text('Submit'), findsOneWidget);
      });

      testWidgets('calls onPressed callback when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Tap me',
            onPressed: () => tapped = true,
          ),
        ));

        await tester.tap(find.text('Tap me'));
        expect(tapped, isTrue);
      });

      testWidgets('renders with default primary variant', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Primary',
            onPressed: () {},
          ),
        ));

        final button = tester.widget<StyloButton>(find.byType(StyloButton));
        expect(button.variant, StyloButtonVariant.primary);
      });

      testWidgets('is full width by default', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Full Width',
            onPressed: () {},
          ),
        ));

        final button = tester.widget<StyloButton>(find.byType(StyloButton));
        expect(button.fullWidth, isTrue);
      });
    });

    group('outlined variant', () {
      testWidgets('renders label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Outlined',
            onPressed: () {},
            variant: StyloButtonVariant.outlined,
          ),
        ));

        expect(find.text('Outlined'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Outlined',
            onPressed: () => tapped = true,
            variant: StyloButtonVariant.outlined,
          ),
        ));

        await tester.tap(find.text('Outlined'));
        expect(tapped, isTrue);
      });
    });

    group('destructive variant', () {
      testWidgets('renders label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Delete',
            onPressed: () {},
            variant: StyloButtonVariant.destructive,
          ),
        ));

        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Delete',
            onPressed: () => tapped = true,
            variant: StyloButtonVariant.destructive,
          ),
        ));

        await tester.tap(find.text('Delete'));
        expect(tapped, isTrue);
      });
    });

    group('text variant', () {
      testWidgets('renders label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Cancel',
            onPressed: () {},
            variant: StyloButtonVariant.text,
          ),
        ));

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Cancel',
            onPressed: () => tapped = true,
            variant: StyloButtonVariant.text,
          ),
        ));

        await tester.tap(find.text('Cancel'));
        expect(tapped, isTrue);
      });
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Submit',
            onPressed: () {},
            isLoading: true,
          ),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not show label text when loading', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Submit',
            onPressed: () {},
            isLoading: true,
          ),
        ));

        expect(find.text('Submit'), findsNothing);
      });

      testWidgets('button is not pressable when loading', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Submit',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ));

        await tester.tap(find.byType(StyloButton));
        expect(tapped, isFalse);
      });
    });

    group('disabled state', () {
      testWidgets('renders label text when disabled', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Disabled',
            onPressed: () {},
            disabled: true,
          ),
        ));

        expect(find.text('Disabled'), findsOneWidget);
      });

      testWidgets('button is not pressable when disabled is true',
          (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Disabled',
            onPressed: () => tapped = true,
            disabled: true,
          ),
        ));

        await tester.tap(find.byType(StyloButton));
        expect(tapped, isFalse);
      });

      testWidgets('button is not pressable when onPressed is null',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          const StyloButton(
            label: 'No Press',
            onPressed: null,
          ),
        ));

        // Should render without throwing
        expect(find.text('No Press'), findsOneWidget);
        // Tapping should not throw
        await tester.tap(find.byType(StyloButton));
        await tester.pump();
      });
    });

    group('icon support', () {
      testWidgets('renders icon when provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.add,
          ),
        ));

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('With Icon'), findsOneWidget);
      });

      testWidgets('renders without icon when not provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'No Icon',
            onPressed: () {},
          ),
        ));

        expect(find.byType(Icon), findsNothing);
        expect(find.text('No Icon'), findsOneWidget);
      });
    });

    group('fullWidth option', () {
      testWidgets('renders correctly when fullWidth is false', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Narrow',
            onPressed: () {},
            fullWidth: false,
          ),
        ));

        expect(find.text('Narrow'), findsOneWidget);
      });

      testWidgets('renders correctly when fullWidth is true', (tester) async {
        await tester.pumpWidget(buildTestApp(
          StyloButton(
            label: 'Wide',
            onPressed: () {},
            fullWidth: true,
          ),
        ));

        expect(find.text('Wide'), findsOneWidget);
      });
    });

    group('StyloButtonVariant enum', () {
      test('enum has primary value', () {
        expect(StyloButtonVariant.primary, isNotNull);
      });

      test('enum has outlined value', () {
        expect(StyloButtonVariant.outlined, isNotNull);
      });

      test('enum has destructive value', () {
        expect(StyloButtonVariant.destructive, isNotNull);
      });

      test('enum has text value', () {
        expect(StyloButtonVariant.text, isNotNull);
      });

      test('enum has exactly 4 values', () {
        expect(StyloButtonVariant.values.length, 4);
      });
    });
  });
}
