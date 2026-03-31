import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme can be applied to MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: Text('Stylo AI')),
        ),
      ),
    );

    expect(find.text('Stylo AI'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
