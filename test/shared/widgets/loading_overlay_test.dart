import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/shared/widgets/loading_overlay.dart';

void main() {
  Widget buildApp({required bool isLoading, String? message}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: LoadingOverlay(
            isLoading: isLoading,
            message: message,
            child: const Text('Content'),
          ),
        ),
      ),
    );
  }

  group('LoadingOverlay', () {
    testWidgets('always renders child', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: false));
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows spinner when loading', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides spinner when not loading', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: false));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows message when provided and loading', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: true, message: 'Cargando...'));
      expect(find.text('Cargando...'), findsOneWidget);
    });

    testWidgets('does not show message when not loading', (tester) async {
      await tester.pumpWidget(buildApp(isLoading: false, message: 'Cargando...'));
      expect(find.text('Cargando...'), findsNothing);
    });
  });
}
