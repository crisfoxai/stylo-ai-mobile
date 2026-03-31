import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';
import 'package:stylo_ai/features/wardrobe/presentation/screens/camera_scanner_screen.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget buildTestWidget() {
  final router = GoRouter(
    initialLocation: '/scan',
    routes: [
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (_, __) => const CameraScannerScreen(),
      ),
      GoRoute(
        path: '/scan-preview',
        name: 'scan-preview',
        builder: (_, __) => const Scaffold(body: Text('Preview')),
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

void main() {
  group('CameraScannerScreen', () {
    testWidgets('renders screen title', (tester) async {
      // Use a phone-like surface size to avoid layout overflow
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Escanear prenda'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders close button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders capture button with camera icon', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders gallery button with label', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.text('Galería'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders instruction text and viewfinder elements', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Viewfinder instruction inside the frame
      expect(
        find.textContaining('Posicioná la prenda'),
        findsOneWidget,
      );
      // Tip text below viewfinder
      expect(
        find.textContaining('bien iluminada y centrada'),
        findsOneWidget,
      );
      // Flash button label
      expect(find.text('Flash'), findsOneWidget);
      expect(find.byIcon(Icons.flash_off_outlined), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
