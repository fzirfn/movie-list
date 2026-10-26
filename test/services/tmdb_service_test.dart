import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/services/tmdb_service.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'TMDB_API_KEY=test_api_key_123');
  });

  group('TmdbService Tests', () {
    test('validates missing or dummy API key', () async {
      dotenv.loadFromString(envString: 'TMDB_API_KEY=your_key_here');
      final service = TmdbService();

      expect(
        () => service.getTrendingMovies(),
        throwsA(
          isA<TmdbException>().having(
            (e) => e.message,
            'message',
            contains('TMDB API key is missing'),
          ),
        ),
      );
    });

    test('parses movie list correctly from dio response', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'page': 1,
                  'results': [
                    {
                      'id': 1,
                      'title': 'Test Movie 1',
                      'poster_path': '/poster1.jpg',
                      'backdrop_path': '/backdrop1.jpg',
                      'vote_average': 7.5,
                      'release_date': '2023-01-01',
                      'overview': 'Overview 1',
                    },
                    {
                      'id': 2,
                      'title': 'Test Movie 2',
                      'poster_path': '/poster2.jpg',
                      'backdrop_path': '/backdrop2.jpg',
                      'vote_average': 8.2,
                      'release_date': '2023-02-02',
                      'overview': 'Overview 2',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);
      final movies = await service.getTrendingMovies();

      expect(movies.length, 2);
      expect(movies[0].id, 1);
      expect(movies[0].title, 'Test Movie 1');
      expect(movies[1].id, 2);
      expect(movies[1].title, 'Test Movie 2');
    });

    test('handles 401 error gracefully with friendly message', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'status_message': 'Invalid API key'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);

      expect(
        () => service.getTrendingMovies(),
        throwsA(
          isA<TmdbException>().having(
            (e) => e.message,
            'message',
            contains('Invalid TMDB API key'),
          ),
        ),
      );
    });

    test('getPopularMovies calls popular endpoint with page', () async {
      final dio = Dio();
      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            requestedParams = options.queryParameters;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'page': 2,
                  'results': [
                    {
                      'id': 10,
                      'title': 'Popular Movie',
                      'vote_average': 8.0,
                      'release_date': '2024-01-01',
                      'overview': 'Popular overview',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);
      final movies = await service.getPopularMovies(page: 2);

      expect(requestedPath, '/movie/popular');
      expect(requestedParams?['page'], 2);
      expect(movies.length, 1);
      expect(movies.first.title, 'Popular Movie');
    });

    test('getTopRatedMovies calls top_rated endpoint with page', () async {
      final dio = Dio();
      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            requestedParams = options.queryParameters;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'page': 3,
                  'results': [
                    {
                      'id': 20,
                      'title': 'Top Rated Movie',
                      'vote_average': 9.2,
                      'release_date': '2024-03-01',
                      'overview': 'Top rated overview',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);
      final movies = await service.getTopRatedMovies(page: 3);

      expect(requestedPath, '/movie/top_rated');
      expect(requestedParams?['page'], 3);
      expect(movies.length, 1);
      expect(movies.first.title, 'Top Rated Movie');
    });

    test('getMovieDetails calls movie detail endpoint with append_to_response=credits', () async {
      final dio = Dio();
      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            requestedParams = options.queryParameters;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 500,
                  'title': 'Detailed Movie',
                  'vote_average': 8.8,
                  'release_date': '2023-10-10',
                  'overview': 'Deep dive overview',
                  'runtime': 120,
                  'genres': [
                    {'id': 28, 'name': 'Action'},
                  ],
                  'credits': {
                    'cast': [
                      {
                        'id': 99,
                        'name': 'Famous Actor',
                        'character': 'Hero',
                        'profile_path': '/hero.jpg',
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);
      final detail = await service.getMovieDetails(500);

      expect(requestedPath, '/movie/500');
      expect(requestedParams?['append_to_response'], 'credits');
      expect(detail.id, 500);
      expect(detail.title, 'Detailed Movie');
      expect(detail.runtimeFormatted, '2h');
      expect(detail.genres, ['Action']);
      expect(detail.cast.length, 1);
      expect(detail.cast.first.name, 'Famous Actor');
    });

    test('searchMovies calls search endpoint with query and page', () async {
      final dio = Dio();
      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            requestedParams = options.queryParameters;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'page': 1,
                  'results': [
                    {
                      'id': 300,
                      'title': 'Dune',
                      'vote_average': 8.3,
                      'release_date': '2021-09-15',
                      'overview': 'Paul Atreides...',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final service = TmdbService(dio: dio);
      final results = await service.searchMovies('Dune', page: 1);

      expect(requestedPath, '/search/movie');
      expect(requestedParams?['query'], 'Dune');
      expect(requestedParams?['page'], 1);
      expect(results.length, 1);
      expect(results.first.title, 'Dune');
    });
  });
}
