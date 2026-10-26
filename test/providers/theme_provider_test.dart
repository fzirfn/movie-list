import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider Tests', () {
    test(
      'default state is ThemeMode.system when no preference saved',
      () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(themeModeProvider.notifier);
        await notifier.loadThemeMode();

        expect(container.read(themeModeProvider), ThemeMode.system);
      },
    );

    test('toggleTheme switches and persists theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      await notifier.toggleTheme(isCurrentlyDark: false);

      expect(container.read(themeModeProvider), ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppConstants.themeStorageKey), 'dark');

      // Toggle back to light
      await notifier.toggleTheme(isCurrentlyDark: true);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(prefs.getString(AppConstants.themeStorageKey), 'light');
    });

    test('loads saved theme mode on startup', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.themeStorageKey: 'dark',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      await notifier.loadThemeMode();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
