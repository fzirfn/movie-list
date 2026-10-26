import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_browser/models/movie_detail.dart';
import 'package:movie_browser/services/tmdb_service.dart';

final movieDetailProvider = FutureProvider.family<MovieDetail, int>((
  ref,
  movieId,
) async {
  final service = ref.watch(tmdbServiceProvider);
  return service.getMovieDetails(movieId);
});
