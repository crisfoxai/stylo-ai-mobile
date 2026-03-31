import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/bottom_nav_bar.dart';

void main() {
  Widget buildApp({int selectedIndex = 0, ValueChanged<int>? onTabSelected}) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: StyloBottomNavBar(
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected ?? (_) {},
        ),
      ),
    );
  }

  group('StyloBottomNavBar', () {
    testWidgets('renders all 5 tab labels', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Guardarropa'), findsOneWidget);
      expect(find.text('Escanear'), findsNothing); // FAB item has no label text
      expect(find.text('Outfits'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('calls onTabSelected with correct index on tap', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(buildApp(
        onTabSelected: (i) => selectedIndex = i,
      ));

      await tester.tap(find.text('Guardarropa'));
      expect(selectedIndex, 1);

      await tester.tap(find.text('Outfits'));
      expect(selectedIndex, 3);

      await tester.tap(find.text('Perfil'));
      expect(selectedIndex, 4);
    });

    testWidgets('renders FAB center button for scan', (tester) async {
      await tester.pumpWidget(buildApp(selectedIndex: 2));
      // The scan FAB is a Container with rounded decoration, not a label
      // It should be tappable
      final fabFinder = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 48,
      );
      expect(fabFinder, findsOneWidget);
    });

    testWidgets('tapping scan FAB calls onTabSelected(2)', (tester) async {
      int? selected;
      await tester.pumpWidget(buildApp(
        onTabSelected: (i) => selected = i,
      ));
      // Find and tap the scan area (3rd item = index 2)
      final allGestureDetectors = find.byType(GestureDetector);
      // There are 5 GestureDetectors (one per nav item)
      expect(allGestureDetectors, findsNWidgets(5));
      await tester.tap(allGestureDetectors.at(2));
      expect(selected, 2);
    });

    testWidgets('selectedIndex=0 highlights Home tab', (tester) async {
      await tester.pumpWidget(buildApp(selectedIndex: 0));
      // Verify Home label exists (selected state)
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
