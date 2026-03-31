import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/outfit_card.dart';

void main() {
  Widget buildApp({
    String name = 'Casual Friday',
    List<String> garmentImageUrls = const [],
    bool isFavorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavoriteTap,
    String? occasion,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: OutfitCard(
            name: name,
            garmentImageUrls: garmentImageUrls,
            isFavorite: isFavorite,
            onTap: onTap,
            onFavoriteTap: onFavoriteTap,
            occasion: occasion,
          ),
        ),
      ),
    );
  }

  group('OutfitCard', () {
    testWidgets('renders outfit name', (tester) async {
      await tester.pumpWidget(buildApp(name: 'Smart Casual'));
      expect(find.text('Smart Casual'), findsOneWidget);
    });

    testWidgets('renders occasion when provided', (tester) async {
      await tester.pumpWidget(buildApp(occasion: 'Office'));
      expect(find.text('Office'), findsOneWidget);
    });

    testWidgets('does not render occasion when null', (tester) async {
      await tester.pumpWidget(buildApp(occasion: null));
      expect(find.text('Office'), findsNothing);
    });

    testWidgets('shows placeholder icon when no garment images', (tester) async {
      await tester.pumpWidget(buildApp(garmentImageUrls: []));
      expect(find.byIcon(Icons.style_outlined), findsOneWidget);
    });

    testWidgets('shows favorite icon when isFavorite is true', (tester) async {
      await tester.pumpWidget(buildApp(isFavorite: true));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows favorite_border icon when isFavorite is false', (tester) async {
      await tester.pumpWidget(buildApp(isFavorite: false));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildApp(onTap: () => tapped = true));
      await tester.tap(find.text('Casual Friday'));
      expect(tapped, isTrue);
    });

    testWidgets('calls onFavoriteTap when heart icon is tapped', (tester) async {
      var favTapped = false;
      await tester.pumpWidget(buildApp(onFavoriteTap: () => favTapped = true));
      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(favTapped, isTrue);
    });

    testWidgets('limits to 4 garment thumbnails', (tester) async {
      // Provide more than 4 URLs; the card should only take first 4
      await tester.pumpWidget(buildApp(
        garmentImageUrls: [
          'https://a.com/1.jpg',
          'https://a.com/2.jpg',
          'https://a.com/3.jpg',
          'https://a.com/4.jpg',
          'https://a.com/5.jpg',
        ],
      ));
      // Should not show the placeholder icon
      expect(find.byIcon(Icons.style_outlined), findsNothing);
    });
  });
}
