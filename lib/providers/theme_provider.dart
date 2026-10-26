import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/services/storage_service.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  bool _isLoaded = false;

  @override
  ThemeMode build() {
    _isLoaded = false;
    Future.microtask(() => loadThemeMode());
    return ThemeMode.system;
  }

  Future<void> loadThemeMode() async {
    if (_isLoaded) return;
    final storage = ref.read(storageServiceProvider);
    final savedMode = await storage.getThemeMode();
    if (savedMode != null) {
      if (savedMode == ThemeMode.dark.name) {
        state = ThemeMode.dark;
      } else if (savedMode == ThemeMode.light.name) {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    }
    _isLoaded = true;
  }

  Future<void> toggleTheme({bool? isCurrentlyDark}) async {
    _isLoaded = true;
    final newMode = (isCurrentlyDark ?? (state == ThemeMode.dark))
        ? ThemeMode.light
        : ThemeMode.dark;
    state = newMode;
    await ref.read(storageServiceProvider).saveThemeMode(newMode.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _isLoaded = true;
    state = mode;
    await ref.read(storageServiceProvider).saveThemeMode(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
