import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/providers/movies_provider.dart';
import 'package:movie_browser/services/tmdb_service.dart';

class MockTmdbService extends TmdbService {
  int trendingCalls = 0;
  int popularCalls = 0;
  int topRatedCalls = 0;

  MockTmdbService() : super(dio: Dio());

  @override
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    trendingCalls++;
    return [
      Movie(
        id: page,
        title: 'Trending Movie Page $page',
        voteAverage: 8.0,
        releaseDate: '2024-01-01',
        overview: 'Overview',
      ),
    ];
  }

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    popularCalls++;
    return [
      Movie(
        id: 100 + page,
        title: 'Popular Movie Page $page',
        voteAverage: 8.5,
        releaseDate: '2024-02-01',
        overview: 'Overview',
      ),
    ];
  }

  @override
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    topRatedCalls++;
    return [
      Movie(
        id: 200 + page,
        title: 'Top Rated Movie Page $page',
        voteAverage: 9.0,
        releaseDate: '2024-03-01',
        overview: 'Overview',
      ),
    ];
  }
}

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'TMDB_API_KEY=test_api_key_123');
  });

  group('Movies Providers Tests', () {
    test(
      'PopularMoviesNotifier loads initial and handles pagination',
      () async {
        final mockService = MockTmdbService();
        final container = ProviderContainer(
          overrides: [tmdbServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        // Trigger build and wait for initial load
        container.read(popularMoviesProvider);
        await Future<void>.delayed(Duration.zero);

        final stateAfterInitial = container.read(popularMoviesProvider);
        expect(stateAfterInitial.movies.length, 1);
        expect(stateAfterInitial.movies.first.title, 'Popular Movie Page 1');
        expect(stateAfterInitial.page, 1);
        expect(stateAfterInitial.isLoading, false);

        // Load next page
        await container.read(popularMoviesProvider.notifier).loadNextPage();

        final stateAfterNextPage = container.read(popularMoviesProvider);
        expect(stateAfterNextPage.movies.length, 2);
        expect(stateAfterNextPage.movies[1].title, 'Popular Movie Page 2');
        expect(stateAfterNextPage.page, 2);

        // Refresh
        await container.read(popularMoviesProvider.notifier).refresh();
        final stateAfterRefresh = container.read(popularMoviesProvider);
        expect(stateAfterRefresh.movies.length, 1);
        expect(stateAfterRefresh.page, 1);
      },
    );

    test(
      'TopRatedMoviesNotifier loads initial and handles pagination',
      () async {
        final mockService = MockTmdbService();
        final container = ProviderContainer(
          overrides: [tmdbServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        container.read(topRatedMoviesProvider);
        await Future<void>.delayed(Duration.zero);

        final stateAfterInitial = container.read(topRatedMoviesProvider);
        expect(stateAfterInitial.movies.length, 1);
        expect(stateAfterInitial.movies.first.title, 'Top Rated Movie Page 1');
        expect(stateAfterInitial.page, 1);

        // Load next page
        await container.read(topRatedMoviesProvider.notifier).loadNextPage();

        final stateAfterNextPage = container.read(topRatedMoviesProvider);
        expect(stateAfterNextPage.movies.length, 2);
        expect(stateAfterNextPage.movies[1].title, 'Top Rated Movie Page 2');
        expect(stateAfterNextPage.page, 2);
      },
    );
  });
}
