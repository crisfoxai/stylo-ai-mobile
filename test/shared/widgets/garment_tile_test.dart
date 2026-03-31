import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/garment_tile.dart';

void main() {
  Widget buildApp({
    String? imageUrl,
    String category = 'Camiseta',
    String? name,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 200,
          width: 150,
          child: GarmentTile(
            imageUrl: imageUrl,
            category: category,
            name: name,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('GarmentTile', () {
    testWidgets('renders category text', (tester) async {
      await tester.pumpWidget(buildApp(category: 'Pantalón'));
      expect(find.text('Pantalón'), findsOneWidget);
    });

    testWidgets('renders name when provided', (tester) async {
      await tester.pumpWidget(buildApp(name: 'Levi 501'));
      expect(find.text('Levi 501'), findsOneWidget);
    });

    testWidgets('does not render name when null', (tester) async {
      await tester.pumpWidget(buildApp(name: null));
      expect(find.text('Levi 501'), findsNothing);
    });

    testWidgets('shows placeholder icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(buildApp(imageUrl: null));
      expect(find.byIcon(Icons.checkroom_outlined), findsOneWidget);
    });

    testWidgets('shows placeholder icon when imageUrl is empty', (tester) async {
      await tester.pumpWidget(buildApp(imageUrl: ''));
      expect(find.byIcon(Icons.checkroom_outlined), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(onTap: () => tapped = true));
      await tester.tap(find.byType(GarmentTile));
      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpWidget(buildApp(onTap: null));
      await tester.tap(find.byType(GarmentTile));
      // No crash = success
    });

    testWidgets('renders both name and category together', (tester) async {
      await tester.pumpWidget(buildApp(name: 'Nike Air', category: 'Zapatilla'));
      expect(find.text('Nike Air'), findsOneWidget);
      expect(find.text('Zapatilla'), findsOneWidget);
    });
  });
}
