import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/try_on/presentation/screens/virtual_try_on_screen.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget() {
  final router = GoRouter(
    initialLocation: '/try-on',
    routes: [
      GoRoute(
        path: '/try-on',
        builder: (_, __) => const VirtualTryOnScreen(),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

Future<void> pumpScreen(WidgetTester tester) async {
  // Use a standard mobile surface to avoid overflow
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(buildTestWidget());
  await tester.pump();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('VirtualTryOnScreen', () {
    testWidgets('renders Próximamente heading', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Próximamente'), findsOneWidget);
    });

    testWidgets('renders feature bullets', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Foto tuya como base virtual'), findsOneWidget);
      expect(find.text('Combina prendas de tu guardarropa'), findsOneWidget);
      expect(find.text('Sugerencias de outfits con IA'), findsOneWidget);
    });

    testWidgets('renders notification button', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Avisarme cuando esté disponible'), findsOneWidget);
    });

    testWidgets('renders app bar with title', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Prueba Virtual'), findsOneWidget);
    });

    testWidgets('renders En desarrollo badge', (tester) async {
      await pumpScreen(tester);
      expect(find.text('En desarrollo'), findsOneWidget);
    });
  });
}
