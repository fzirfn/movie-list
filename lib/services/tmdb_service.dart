import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/models/movie.dart';
import 'package:movie_browser/models/movie_detail.dart';

final tmdbServiceProvider = Provider<TmdbService>((ref) {
  return TmdbService();
});

class TmdbException implements Exception {
  final String message;
  final int? statusCode;

  const TmdbException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class TmdbService {
  final Dio _dio;

  TmdbService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = AppConstants.tmdbBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final apiKey = dotenv.maybeGet(AppConstants.envApiKey) ?? '';
          options.queryParameters['api_key'] = apiKey;
          return handler.next(options);
        },
      ),
    );
  }

  void _validateApiKey() {
    final apiKey = dotenv.maybeGet(AppConstants.envApiKey) ?? '';
    if (apiKey.isEmpty || apiKey == 'your_key_here') {
      throw const TmdbException(
        'TMDB API key is missing. Please add your TMDB_API_KEY to the .env file.',
        statusCode: 401,
      );
    }
  }

  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    _validateApiKey();
    try {
      final response = await _dio.get(
        AppConstants.trendingMoviesEndpoint,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is TmdbException) rethrow;
      throw TmdbException('Failed to load trending movies: $e');
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    _validateApiKey();
    try {
      final response = await _dio.get(
        AppConstants.popularMoviesEndpoint,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is TmdbException) rethrow;
      throw TmdbException('Failed to load popular movies: $e');
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    _validateApiKey();
    try {
      final response = await _dio.get(
        AppConstants.topRatedMoviesEndpoint,
        queryParameters: {'page': page},
      );
      return _parseMovieList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is TmdbException) rethrow;
      throw TmdbException('Failed to load top rated movies: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    _validateApiKey();
    try {
      final response = await _dio.get(
        AppConstants.searchMoviesEndpoint,
        queryParameters: {'query': query, 'page': page},
      );
      return _parseMovieList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is TmdbException) rethrow;
      throw TmdbException('Failed to search movies: $e');
    }
  }

  Future<MovieDetail> getMovieDetails(int id) async {
    _validateApiKey();
    try {
      final response = await _dio.get(
        '${AppConstants.movieDetailsEndpoint}/$id',
        queryParameters: {'append_to_response': 'credits'},
      );
      if (response.data is Map<String, dynamic>) {
        return MovieDetail.fromJson(response.data as Map<String, dynamic>);
      }
      throw const TmdbException('Invalid response format for movie details.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is TmdbException) rethrow;
      throw TmdbException('Failed to load movie details: $e');
    }
  }

  List<Movie> _parseMovieList(dynamic data) {
    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = data['results'] as List;
      return results
          .whereType<Map<String, dynamic>>()
          .map((json) => Movie.fromJson(json))
          .toList();
    }
    return [];
  }

  TmdbException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TmdbException(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return const TmdbException(
          'No internet connection. Please check your network and try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const TmdbException(
            'Invalid TMDB API key. Please check your TMDB_API_KEY in .env.',
            statusCode: 401,
          );
        } else if (statusCode == 404) {
          return const TmdbException(
            'The requested movie or resource was not found.',
            statusCode: 404,
          );
        }
        final statusMessage = e.response?.data is Map
            ? e.response?.data['status_message'] as String?
            : null;
        return TmdbException(
          statusMessage ?? 'Server error ($statusCode). Please try again.',
          statusCode: statusCode,
        );
      default:
        if (e.error is SocketException) {
          return const TmdbException(
            'No internet connection. Please check your network.',
          );
        }
        return TmdbException(
          e.message ?? 'An unexpected error occurred. Please try again.',
        );
    }
  }
}
