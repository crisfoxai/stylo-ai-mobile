import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/error_view.dart';
import 'package:stylo_ai/shared/widgets/stylo_button.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('ErrorView', () {
    group('basic rendering', () {
      testWidgets('renders without throwing', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Something went wrong'),
        ));

        expect(find.byType(ErrorView), findsOneWidget);
      });

      testWidgets('renders the error message', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Unable to load data'),
        ));

        expect(find.text('Unable to load data'), findsOneWidget);
      });

      testWidgets('renders the fixed heading "Algo salió mal"', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Network error'),
        ));

        expect(find.text('Algo salió mal'), findsOneWidget);
      });

      testWidgets('is centered in its container', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error'),
        ));

        // ErrorView wraps its content in a Center; there may be more than one
        // Center in the widget tree (e.g. from MaterialApp/Scaffold internals).
        expect(find.byType(Center), findsAtLeastNWidgets(1));
      });

      testWidgets('renders a Column layout', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error'),
        ));

        expect(find.byType(Column), findsOneWidget);
      });
    });

    group('icon container', () {
      testWidgets('renders an icon', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error'),
        ));

        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('icon has size 36', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error'),
        ));

        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(icon.size, 36);
      });
    });

    group('retry button', () {
      testWidgets('does not show retry button when onRetry is null',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(
            message: 'Error occurred',
            onRetry: null,
          ),
        ));

        expect(find.byType(StyloButton), findsNothing);
      });

      testWidgets('shows retry button when onRetry is provided', (tester) async {
        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error occurred',
            onRetry: () {},
          ),
        ));

        expect(find.byType(StyloButton), findsOneWidget);
      });

      testWidgets('retry button shows default label "Reintentar"', (tester) async {
        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ));

        expect(find.text('Reintentar'), findsOneWidget);
      });

      testWidgets('retry button shows custom retryLabel when provided',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error',
            onRetry: () {},
            retryLabel: 'Try Again',
          ),
        ));

        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Reintentar'), findsNothing);
      });

      testWidgets('retry button calls onRetry callback when tapped',
          (tester) async {
        var retryCalled = false;

        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error',
            onRetry: () => retryCalled = true,
          ),
        ));

        await tester.tap(find.byType(StyloButton));
        expect(retryCalled, isTrue);
      });

      testWidgets('retry button uses outlined variant', (tester) async {
        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ));

        final button = tester.widget<StyloButton>(find.byType(StyloButton));
        expect(button.variant, StyloButtonVariant.outlined);
      });

      testWidgets('retry button is not full width', (tester) async {
        await tester.pumpWidget(buildTestApp(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ));

        final button = tester.widget<StyloButton>(find.byType(StyloButton));
        expect(button.fullWidth, isFalse);
      });
    });

    group('layout structure', () {
      testWidgets('renders heading above the error message', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Detailed error info'),
        ));

        final headingFinder = find.text('Algo salió mal');
        final messageFinder = find.text('Detailed error info');

        expect(headingFinder, findsOneWidget);
        expect(messageFinder, findsOneWidget);

        final headingPosition = tester.getTopLeft(headingFinder);
        final messagePosition = tester.getTopLeft(messageFinder);

        // Heading appears above (smaller y) than the message
        expect(headingPosition.dy, lessThan(messagePosition.dy));
      });

      testWidgets('renders icon above heading', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error'),
        ));

        final iconFinder = find.byType(Icon);
        final headingFinder = find.text('Algo salió mal');

        final iconPosition = tester.getTopLeft(iconFinder);
        final headingPosition = tester.getTopLeft(headingFinder);

        // Icon appears above the heading
        expect(iconPosition.dy, lessThan(headingPosition.dy));
      });
    });

    group('different messages', () {
      testWidgets('renders network error message', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Sin conexión a internet'),
        ));

        expect(find.text('Sin conexión a internet'), findsOneWidget);
      });

      testWidgets('renders server error message', (tester) async {
        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: 'Error del servidor'),
        ));

        expect(find.text('Error del servidor'), findsOneWidget);
      });

      testWidgets('renders long error message without overflow', (tester) async {
        const longMessage =
            'An unexpected error occurred while processing your request. '
            'Please try again later or contact support if the problem persists.';

        await tester.pumpWidget(buildTestApp(
          const ErrorView(message: longMessage),
        ));

        expect(find.text(longMessage), findsOneWidget);
      });
    });
  });
}
