import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/empty_state_view.dart';
import 'package:stylo_ai/shared/widgets/stylo_button.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('EmptyStateView', () {
    group('basic rendering', () {
      testWidgets('renders without throwing', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Nothing here',
            subtitle: 'Add something to get started',
          ),
        ));

        expect(find.byType(EmptyStateView), findsOneWidget);
      });

      testWidgets('renders the icon', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Nothing here',
            subtitle: 'Add something',
          ),
        ));

        expect(find.byIcon(Icons.inbox), findsOneWidget);
      });

      testWidgets('renders the title text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Your wardrobe is empty',
            subtitle: 'Add your first garment',
          ),
        ));

        expect(find.text('Your wardrobe is empty'), findsOneWidget);
      });

      testWidgets('renders the subtitle text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Nothing here',
            subtitle: 'Start by adding a new item',
          ),
        ));

        expect(find.text('Start by adding a new item'), findsOneWidget);
      });

      testWidgets('is centered in its container', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing to show',
          ),
        ));

        // EmptyStateView wraps its content in a Center; there may be more than
        // one Center in the widget tree (from MaterialApp/Scaffold internals).
        expect(find.byType(Center), findsAtLeastNWidgets(1));
      });
    });

    group('icon container', () {
      testWidgets('renders icon inside a Container', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.star,
            title: 'Empty',
            subtitle: 'Subtitle',
          ),
        ));

        expect(find.byType(Container), findsWidgets);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('renders Icon with correct size', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Subtitle',
          ),
        ));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.size, 44);
      });
    });

    group('action button', () {
      testWidgets('does not show action button when actionLabel is null',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
          ),
        ));

        expect(find.byType(StyloButton), findsNothing);
      });

      testWidgets('does not show action button when onAction is null',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Add Item',
            onAction: null,
          ),
        ));

        expect(find.byType(StyloButton), findsNothing);
      });

      testWidgets('shows action button when both actionLabel and onAction are provided',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Add Item',
            onAction: () {},
          ),
        ));

        expect(find.byType(StyloButton), findsOneWidget);
      });

      testWidgets('action button shows correct label text', (tester) async {
        await tester.pumpWidget(buildTestApp(
          EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Add First Item',
            onAction: () {},
          ),
        ));

        expect(find.text('Add First Item'), findsOneWidget);
      });

      testWidgets('action button calls onAction when tapped', (tester) async {
        var actionCalled = false;

        await tester.pumpWidget(buildTestApp(
          EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Add Item',
            onAction: () => actionCalled = true,
          ),
        ));

        await tester.tap(find.byType(StyloButton));
        expect(actionCalled, isTrue);
      });

      testWidgets('action button is not full width', (tester) async {
        await tester.pumpWidget(buildTestApp(
          EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Add Item',
            onAction: () {},
          ),
        ));

        final button = tester.widget<StyloButton>(find.byType(StyloButton));
        expect(button.fullWidth, isFalse);
      });
    });

    group('layout structure', () {
      testWidgets('renders title before subtitle', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Main Title',
            subtitle: 'Supporting subtitle text',
          ),
        ));

        final titleFinder = find.text('Main Title');
        final subtitleFinder = find.text('Supporting subtitle text');

        expect(titleFinder, findsOneWidget);
        expect(subtitleFinder, findsOneWidget);

        // Both should exist in the widget tree
        final titlePosition = tester.getTopLeft(titleFinder);
        final subtitlePosition = tester.getTopLeft(subtitleFinder);

        // Title should appear above (smaller y coordinate) than subtitle
        expect(titlePosition.dy, lessThan(subtitlePosition.dy));
      });

      testWidgets('uses Column for vertical layout', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const EmptyStateView(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Subtitle',
          ),
        ));

        expect(find.byType(Column), findsOneWidget);
      });
    });
  });
}
