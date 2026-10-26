import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/providers/search_provider.dart';
import 'package:movie_browser/services/tmdb_service.dart';

class MockSearchTmdbService extends TmdbService {
  MockSearchTmdbService() : super(dio: Dio());

  @override
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query == 'empty') return [];
    return [
      Movie(
        id: page,
        title: '$query Movie Page $page',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        overview: 'Overview for $query',
      ),
    ];
  }
}

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'TMDB_API_KEY=test_api_key_123');
  });

  group('SearchProvider Tests', () {
    test('initial state has no query and hasSearched is false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(searchProvider);
      expect(state.query, '');
      expect(state.movies, isEmpty);
      expect(state.hasSearched, false);
      expect(state.isLoading, false);
    });

    test('search updates query and loads results', () async {
      final mockService = MockSearchTmdbService();
      final container = ProviderContainer(
        overrides: [tmdbServiceProvider.overrideWithValue(mockService)],
      );
      addTearDown(container.dispose);

      await container.read(searchProvider.notifier).search('Inception');

      final state = container.read(searchProvider);
      expect(state.query, 'Inception');
      expect(state.hasSearched, true);
      expect(state.movies.length, 1);
      expect(state.movies.first.title, 'Inception Movie Page 1');
      expect(state.page, 1);
      expect(state.isLoading, false);
    });

    test('loadNextPage appends paginated search results', () async {
      final mockService = MockSearchTmdbService();
      final container = ProviderContainer(
        overrides: [tmdbServiceProvider.overrideWithValue(mockService)],
      );
      addTearDown(container.dispose);

      await container.read(searchProvider.notifier).search('Batman');
      await container.read(searchProvider.notifier).loadNextPage();

      final state = container.read(searchProvider);
      expect(state.movies.length, 2);
      expect(state.movies[0].title, 'Batman Movie Page 1');
      expect(state.movies[1].title, 'Batman Movie Page 2');
      expect(state.page, 2);
    });

    test('clear resets search state to hint state', () async {
      final mockService = MockSearchTmdbService();
      final container = ProviderContainer(
        overrides: [tmdbServiceProvider.overrideWithValue(mockService)],
      );
      addTearDown(container.dispose);

      await container.read(searchProvider.notifier).search('Avatar');
      expect(container.read(searchProvider).hasSearched, true);

      container.read(searchProvider.notifier).clear();
      final clearedState = container.read(searchProvider);
      expect(clearedState.query, '');
      expect(clearedState.movies, isEmpty);
      expect(clearedState.hasSearched, false);
    });
  });
}
