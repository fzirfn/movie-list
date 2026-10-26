import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final SharedPreferences? _prefsInstance;

  StorageService({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  // --- Favorites Persistence ---

  Future<List<Movie>> getFavorites() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(AppConstants.favoritesStorageKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => Movie.fromJson(item))
            .toList();
      }
    } catch (_) {
      // If corrupted, return empty
    }
    return [];
  }

  Future<void> saveFavorites(List<Movie> movies) async {
    final prefs = await _getPrefs();
    final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
    await prefs.setString(AppConstants.favoritesStorageKey, encoded);
  }

  // --- Theme Mode Persistence ---

  Future<String?> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConstants.themeStorageKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.themeStorageKey, themeMode);
  }
}
