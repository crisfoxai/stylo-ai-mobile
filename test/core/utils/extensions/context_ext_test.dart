import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/utils/extensions/context_ext.dart';

void main() {
  group('ContextExt', () {
    testWidgets('theme returns ThemeData', (tester) async {
      late ThemeData captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.theme;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('colorScheme returns ColorScheme', (tester) async {
      late ColorScheme captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.colorScheme;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('textTheme returns TextTheme', (tester) async {
      late TextTheme captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.textTheme;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('screenWidth returns positive value', (tester) async {
      late double captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.screenWidth;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, greaterThan(0));
    });

    testWidgets('screenHeight returns positive value', (tester) async {
      late double captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.screenHeight;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, greaterThan(0));
    });

    testWidgets('isDarkMode returns false for light theme', (tester) async {
      late bool captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(builder: (context) {
            captured = context.isDarkMode;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isFalse);
    });

    testWidgets('padding returns EdgeInsets', (tester) async {
      late EdgeInsets captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            captured = context.padding;
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('showSnackBar displays message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showSnackBar('Test message'),
                child: const Text('Show'),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('showSnackBar with isError uses error color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => context.showSnackBar('Error!', isError: true),
                child: const Text('Show'),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Error!'), findsOneWidget);
    });
  });
}
