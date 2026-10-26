import 'package:movie_browser/core/constants.dart';
import 'package:movie_browser/models/cast_member.dart';
import 'package:movie_browser/models/movie.dart';

class MovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String overview;
  final int? runtime;
  final List<String> genres;
  final List<CastMember> cast;

  const MovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.overview,
    this.runtime,
    this.genres = const [],
    this.cast = const [],
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .whereType<Map<String, dynamic>>()
          .map((g) => (g['name'] as String?) ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }

    List<CastMember> parsedCast = [];
    if (json['credits'] is Map<String, dynamic> &&
        json['credits']['cast'] is List) {
      final rawCast = json['credits']['cast'] as List;
      parsedCast = rawCast
          .whereType<Map<String, dynamic>>()
          .take(AppConstants.topCastLimit)
          .map((c) => CastMember.fromJson(c))
          .toList();
    }

    return MovieDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? (json['name'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['release_date'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      runtime: (json['runtime'] as num?)?.toInt(),
      genres: parsedGenres,
      cast: parsedCast,
    );
  }

  factory MovieDetail.fromMovie(Movie movie) {
    return MovieDetail(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      overview: movie.overview,
      runtime: null,
      genres: const [],
      cast: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'overview': overview,
      'runtime': runtime,
      'genres': genres.map((name) => {'name': name}).toList(),
      'credits': {'cast': cast.map((c) => c.toJson()).toList()},
    };
  }

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      overview: overview,
    );
  }

  String get posterUrl => AppConstants.posterUrl(posterPath);
  String get backdropUrl => AppConstants.backdropUrl(backdropPath);

  String get releaseYear {
    if (releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }
    return '';
  }

  String get voteAverageFormatted => voteAverage.toStringAsFixed(1);

  String get runtimeFormatted {
    if (runtime == null || runtime! <= 0) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
