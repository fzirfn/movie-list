import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/services/tmdb_service.dart';

class PaginatedMoviesState {
  final List<Movie> movies;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;

  const PaginatedMoviesState({
    this.movies = const [],
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
  });

  PaginatedMoviesState copyWith({
    List<Movie>? movies,
    int? page,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaginatedMoviesState(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TrendingMoviesNotifier extends Notifier<PaginatedMoviesState> {
  @override
  PaginatedMoviesState build() {
    Future.microtask(() => loadInitial());
    return const PaginatedMoviesState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(tmdbServiceProvider);
      final movies = await service.getTrendingMovies(page: 1);
      state = PaginatedMoviesState(
        movies: movies,
        page: 1,
        isLoading: false,
        hasMore: movies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    try {
      final service = ref.read(tmdbServiceProvider);
      final newMovies = await service.getTrendingMovies(page: nextPage);
      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        page: nextPage,
        isLoading: false,
        hasMore: newMovies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final trendingMoviesProvider =
    NotifierProvider<TrendingMoviesNotifier, PaginatedMoviesState>(
      TrendingMoviesNotifier.new,
    );

class PopularMoviesNotifier extends Notifier<PaginatedMoviesState> {
  @override
  PaginatedMoviesState build() {
    Future.microtask(() => loadInitial());
    return const PaginatedMoviesState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(tmdbServiceProvider);
      final movies = await service.getPopularMovies(page: 1);
      state = PaginatedMoviesState(
        movies: movies,
        page: 1,
        isLoading: false,
        hasMore: movies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    try {
      final service = ref.read(tmdbServiceProvider);
      final newMovies = await service.getPopularMovies(page: nextPage);
      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        page: nextPage,
        isLoading: false,
        hasMore: newMovies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final popularMoviesProvider =
    NotifierProvider<PopularMoviesNotifier, PaginatedMoviesState>(
      PopularMoviesNotifier.new,
    );

class TopRatedMoviesNotifier extends Notifier<PaginatedMoviesState> {
  @override
  PaginatedMoviesState build() {
    Future.microtask(() => loadInitial());
    return const PaginatedMoviesState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(tmdbServiceProvider);
      final movies = await service.getTopRatedMovies(page: 1);
      state = PaginatedMoviesState(
        movies: movies,
        page: 1,
        isLoading: false,
        hasMore: movies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    try {
      final service = ref.read(tmdbServiceProvider);
      final newMovies = await service.getTopRatedMovies(page: nextPage);
      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        page: nextPage,
        isLoading: false,
        hasMore: newMovies.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final topRatedMoviesProvider =
    NotifierProvider<TopRatedMoviesNotifier, PaginatedMoviesState>(
      TopRatedMoviesNotifier.new,
    );
