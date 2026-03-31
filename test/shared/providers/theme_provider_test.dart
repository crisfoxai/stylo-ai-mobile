import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylo_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:stylo_ai/shared/providers/theme_provider.dart';

void main() {
  group('ThemeModeNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    test('defaults to ThemeMode.system', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('loads dark mode from preferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final darkPrefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(darkPrefs)],
      );
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('loads light mode from preferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final lightPrefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(lightPrefs)],
      );
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('setThemeMode to dark persists', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('setThemeMode to light persists', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('setThemeMode to system removes key', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(prefs.getString('theme_mode'), isNull);
    });

    test('toggleTheme switches light to dark', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('toggleTheme switches dark to light', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await container.read(themeModeProvider.notifier).toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('isDark returns correct value', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider.notifier).isDark, isFalse);
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider.notifier).isDark, isTrue);
    });
  });
}
