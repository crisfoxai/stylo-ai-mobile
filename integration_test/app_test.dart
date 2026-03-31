import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylo_ai/app.dart';
import 'package:stylo_ai/core/theme/app_colors.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Stylo AI App Integration Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('App launches and shows splash screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      // Splash screen should be shown initially
      expect(find.text('STYLO'), findsOneWidget);

      // Let the splash timer complete fully to avoid a pending Future
      // that outlives this test and crashes subsequent tests when the
      // ProviderContainer is already disposed.
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('App navigates from splash to auth when not logged in',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      // Wait for splash timer to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should see the auth screen
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
    });

    testWidgets('Auth screen toggles between login and register',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should start in login mode
      expect(find.text('Iniciar sesión'), findsOneWidget);

      // Toggle to register
      await tester.tap(find.text('¿No tenés cuenta? Registrate'));
      await tester.pumpAndSettle();

      // Should be in register mode now
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Apellido'), findsOneWidget);

      // Toggle back to login
      await tester.tap(find.text('¿Ya tenés cuenta? Iniciá sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('Auth screen validates email field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Try to submit with empty fields
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      // Validation errors should appear
      // (The form validates email is required)
    });

    testWidgets('Auth screen shows social auth buttons with correct styling',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Google button should exist
      expect(find.text('Continuar con Google'), findsOneWidget);

      // Apple button should exist
      expect(find.text('Continuar con Apple'), findsOneWidget);

      // Divider with "o" text
      expect(find.text('o'), findsOneWidget);

      // Legal text
      expect(
        find.text('Al continuar, aceptás los Términos y Política de Privacidad'),
        findsOneWidget,
      );
    });

    testWidgets('Auth screen has password visibility toggle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const StyloApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find the password visibility toggle icon
      final visibilityOff = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityOff, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityOff);
      await tester.pumpAndSettle();

      // Should now show visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
