import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/stylo_card.dart';

void main() {
  Widget buildApp({Widget? child, VoidCallback? onTap, bool showShadow = true}) {
    return MaterialApp(
      home: Scaffold(
        body: StyloCard(
          onTap: onTap,
          showShadow: showShadow,
          child: child ?? const Text('Card content'),
        ),
      ),
    );
  }

  group('StyloCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(onTap: () => tapped = true));
      await tester.tap(find.text('Card content'));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap in GestureDetector when onTap is null', (tester) async {
      await tester.pumpWidget(buildApp(onTap: null));
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('renders without shadow when showShadow is false', (tester) async {
      await tester.pumpWidget(buildApp(showShadow: false));
      expect(find.text('Card content'), findsOneWidget);
    });
  });
}
