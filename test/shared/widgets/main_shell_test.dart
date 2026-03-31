import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/shared/widgets/main_shell.dart';
import 'package:stylo_ai/shared/widgets/bottom_nav_bar.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget({String initialLocation = '/home'}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Text('Home Content'),
          ),
          GoRoute(
            path: '/wardrobe',
            builder: (_, __) => const Text('Wardrobe Content'),
          ),
          GoRoute(
            path: '/scan',
            builder: (_, __) => const Text('Scan Content'),
          ),
          GoRoute(
            path: '/outfits',
            builder: (_, __) => const Text('Outfits Content'),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const Text('Profile Content'),
          ),
        ],
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

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('MainShell', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Home Content'), findsOneWidget);
    });

    testWidgets('renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(StyloBottomNavBar), findsOneWidget);
    });

    testWidgets('renders correct child for wardrobe route', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(initialLocation: '/wardrobe'),
      );
      await tester.pump();

      expect(find.text('Wardrobe Content'), findsOneWidget);
    });

    testWidgets('displays nav bar labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Guardarropa'), findsOneWidget);
      // 'Escanear' is the FAB center button — rendered as icon only, no label
      expect(find.text('Outfits'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });
  });
}
