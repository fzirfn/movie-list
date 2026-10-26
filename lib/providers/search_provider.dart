import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/services/tmdb_service.dart';

class SearchState {
  final String query;
  final List<Movie> movies;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final bool hasSearched;

  const SearchState({
    this.query = '',
    this.movies = const [],
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.hasSearched = false,
  });

  SearchState copyWith({
    String? query,
    List<Movie>? movies,
    int? page,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool? hasSearched,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      movies: movies ?? this.movies,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  void onQueryChanged(String newQuery) {
    _debounceTimer?.cancel();

    final trimmed = newQuery.trim();
    if (trimmed.isEmpty) {
      state = const SearchState();
      return;
    }

    _debounceTimer = Timer(AppConstants.searchDebounceDuration, () {
      search(trimmed);
    });
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: trimmed,
      isLoading: true,
      hasSearched: true,
      clearError: true,
    );

    try {
      final service = ref.read(tmdbServiceProvider);
      final movies = await service.searchMovies(trimmed, page: 1);
      state = state.copyWith(
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
    if (state.isLoading || !state.hasMore || state.query.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.page + 1;
    try {
      final service = ref.read(tmdbServiceProvider);
      final newMovies = await service.searchMovies(state.query, page: nextPage);
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

  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
