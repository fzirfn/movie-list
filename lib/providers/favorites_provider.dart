import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/services/storage_service.dart';

class FavoritesNotifier extends Notifier<List<Movie>> {
  bool _isLoaded = false;

  @override
  List<Movie> build() {
    _isLoaded = false;
    Future.microtask(() => loadFavorites());
    return const [];
  }

  Future<void> loadFavorites() async {
    if (_isLoaded && state.isNotEmpty) return;
    final storage = ref.read(storageServiceProvider);
    final movies = await storage.getFavorites();
    state = movies;
    _isLoaded = true;
  }

  bool isFavorite(int movieId) {
    return state.any((m) => m.id == movieId);
  }

  Future<bool> toggleFavorite(Movie movie) async {
    _isLoaded = true;
    final storage = ref.read(storageServiceProvider);
    final exists = isFavorite(movie.id);

    final List<Movie> updated;
    if (exists) {
      updated = state.where((m) => m.id != movie.id).toList();
    } else {
      updated = [...state, movie];
    }

    state = updated;
    await storage.saveFavorites(updated);
    return !exists;
  }

  Future<void> removeFavorite(int movieId) async {
    _isLoaded = true;
    final storage = ref.read(storageServiceProvider);
    final updated = state.where((m) => m.id != movieId).toList();
    state = updated;
    await storage.saveFavorites(updated);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Movie>>(
  FavoritesNotifier.new,
);

final isMovieFavoriteProvider = Provider.family<bool, int>((ref, movieId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((m) => m.id == movieId);
});
