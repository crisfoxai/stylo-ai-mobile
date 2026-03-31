import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stylo_ai/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:stylo_ai/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:stylo_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:stylo_ai/core/theme/app_theme.dart';

// ── Fake data source ──────────────────────────────────────────────────────────

class FakeOnboardingDataSource implements OnboardingLocalDataSource {
  bool _onboardingComplete = false;
  bool _styleQuizComplete = false;
  bool setOnboardingCompleteCalled = false;

  @override
  bool get isOnboardingComplete => _onboardingComplete;

  @override
  Future<void> setOnboardingComplete() async {
    setOnboardingCompleteCalled = true;
    _onboardingComplete = true;
  }

  @override
  bool get hasCompletedStyleQuiz => _styleQuizComplete;

  @override
  Future<void> setStyleQuizComplete() async {
    _styleQuizComplete = true;
  }
}

// ── Builder ───────────────────────────────────────────────────────────────────

Widget buildOnboarding(FakeOnboardingDataSource fakeDs) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const Scaffold(body: Text('Auth Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      onboardingDataSourceProvider.overrideWithValue(fakeDs),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  late FakeOnboardingDataSource fakeDs;

  setUp(() {
    fakeDs = FakeOnboardingDataSource();
  });

  group('OnboardingScreen', () {
    testWidgets('renders the first slide title', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(find.text('Escaneá tu guardarropa'), findsOneWidget);
    });

    testWidgets('renders the first slide subtitle', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(
        find.textContaining('Tomá una foto y la IA organiza todo'),
        findsOneWidget,
      );
    });

    testWidgets('renders a PageView', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('renders page indicator dots (3 animated containers)',
        (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      // 3 AnimatedContainers are used for the dots
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders "Siguiente" button on first page', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(find.text('Siguiente'), findsOneWidget);
    });

    testWidgets('renders "Saltar" button on first page', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(find.text('Saltar'), findsOneWidget);
    });

    testWidgets('navigates to second slide on "Siguiente" tap', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Outfits pensados para vos'), findsOneWidget);
    });

    testWidgets('navigates to third slide from second slide', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Tu estilo evoluciona con vos'), findsOneWidget);
    });

    testWidgets('renders "Empezar" button on last slide', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Empezar'), findsOneWidget);
    });

    testWidgets('"Saltar" is not shown on last slide', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Saltar'), findsNothing);
    });

    testWidgets('tapping "Saltar" calls setOnboardingComplete and navigates',
        (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();

      expect(fakeDs.setOnboardingCompleteCalled, isTrue);
      // Navigation to /auth should have occurred
      expect(find.text('Auth Screen'), findsOneWidget);
    });

    testWidgets(
        'tapping "Empezar" on last slide calls setOnboardingComplete and navigates',
        (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Empezar'));
      await tester.pumpAndSettle();

      expect(fakeDs.setOnboardingCompleteCalled, isTrue);
      expect(find.text('Auth Screen'), findsOneWidget);
    });

    testWidgets('slide icons are rendered', (tester) async {
      await tester.pumpWidget(buildOnboarding(fakeDs));
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });
  });
}
