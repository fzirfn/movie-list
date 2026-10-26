class AppConstants {
  AppConstants._();

  // TMDB API Endpoints & URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String posterSize = 'w500';
  static const String backdropSize = 'w780';

  // API Key Environment Variable
  static const String envApiKey = 'TMDB_API_KEY';

  // Endpoints
  static const String trendingMoviesEndpoint = '/trending/movie/week';
  static const String popularMoviesEndpoint = '/movie/popular';
  static const String topRatedMoviesEndpoint = '/movie/top_rated';
  static const String searchMoviesEndpoint = '/search/movie';
  static const String movieDetailsEndpoint = '/movie';

  // Local Storage Keys
  static const String favoritesStorageKey = 'favorite_movies';
  static const String themeStorageKey = 'theme_mode';

  // Durations & Limits
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);
  static const int topCastLimit = 10;

  // Image URL Helpers
  static String posterUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl$posterSize$path';
  }

  static String backdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl$backdropSize$path';
  }
}
