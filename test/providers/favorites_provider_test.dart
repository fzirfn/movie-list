import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testMovie1 = Movie(
    id: 1,
    title: 'Interstellar',
    posterPath: '/interstellar.jpg',
    backdropPath: '/interstellar_back.jpg',
    voteAverage: 8.7,
    releaseDate: '2014-11-05',
    overview: 'Mankind was born on Earth...',
  );

  const testMovie2 = Movie(
    id: 2,
    title: 'Inception',
    posterPath: '/inception.jpg',
    backdropPath: '/inception_back.jpg',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
    overview: 'Your mind is the scene of the crime...',
  );

  group('FavoritesProvider Tests', () {
    test('initial state loads empty when SharedPreferences is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.loadFavorites();

      final state = container.read(favoritesProvider);
      expect(state, isEmpty);
      expect(notifier.isFavorite(1), false);
    });

    test('toggleFavorite adds a movie and persists it', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      final added = await notifier.toggleFavorite(testMovie1);

      expect(added, true);
      expect(container.read(favoritesProvider).length, 1);
      expect(container.read(favoritesProvider).first.id, 1);
      expect(notifier.isFavorite(1), true);

      // Verify persistence directly in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(AppConstants.favoritesStorageKey);
      expect(storedJson, isNotNull);
      final decoded = jsonDecode(storedJson!) as List;
      expect(decoded.length, 1);
      expect(decoded[0]['title'], 'Interstellar');
    });

    test('toggleFavorite on existing movie removes it', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.toggleFavorite(testMovie1);
      expect(notifier.isFavorite(1), true);

      final added = await notifier.toggleFavorite(testMovie1);
      expect(added, false);
      expect(container.read(favoritesProvider), isEmpty);
      expect(notifier.isFavorite(1), false);
    });

    test(
      'removeFavorite removes specified movie from state and storage',
      () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(favoritesProvider.notifier);
        await notifier.toggleFavorite(testMovie1);
        await notifier.toggleFavorite(testMovie2);
        expect(container.read(favoritesProvider).length, 2);

        await notifier.removeFavorite(testMovie1.id);

        final remaining = container.read(favoritesProvider);
        expect(remaining.length, 1);
        expect(remaining.first.id, 2);
        expect(notifier.isFavorite(1), false);
        expect(notifier.isFavorite(2), true);
      },
    );

    test('loads saved favorites on initial load', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.favoritesStorageKey: jsonEncode([testMovie1.toJson()]),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      await notifier.loadFavorites();

      final state = container.read(favoritesProvider);
      expect(state.length, 1);
      expect(state.first.title, 'Interstellar');
      expect(notifier.isFavorite(1), true);
    });
  });
}
