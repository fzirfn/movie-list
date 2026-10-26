import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/models/movie.dart';

void main() {
  group('Movie Model Tests', () {
    test('Movie.fromJson parses complete JSON accurately', () {
      final json = {
        'id': 550,
        'title': 'Fight Club',
        'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        'backdrop_path': '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
        'vote_average': 8.433,
        'release_date': '1999-10-15',
        'overview': 'An insomniac office worker...',
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.posterPath, '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg');
      expect(movie.backdropPath, '/hZkgoQYus5vegHoetLkCJzb17zJ.jpg');
      expect(movie.voteAverage, 8.433);
      expect(movie.releaseDate, '1999-10-15');
      expect(movie.overview, 'An insomniac office worker...');
      expect(movie.releaseYear, '1999');
      expect(movie.voteAverageFormatted, '8.4');
      expect(movie.posterUrl, contains('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
    });

    test('Movie.fromJson handles missing or null fields gracefully', () {
      final json = <String, dynamic>{'id': 123};

      final movie = Movie.fromJson(json);

      expect(movie.id, 123);
      expect(movie.title, '');
      expect(movie.posterPath, null);
      expect(movie.backdropPath, null);
      expect(movie.voteAverage, 0.0);
      expect(movie.releaseDate, '');
      expect(movie.releaseYear, '');
      expect(movie.overview, '');
      expect(movie.posterUrl, '');
    });

    test('Movie.toJson produces expected map', () {
      const movie = Movie(
        id: 101,
        title: 'Interstellar',
        posterPath: '/path.jpg',
        backdropPath: '/back.jpg',
        voteAverage: 8.7,
        releaseDate: '2014-11-05',
        overview: 'A team of explorers...',
      );

      final json = movie.toJson();

      expect(json['id'], 101);
      expect(json['title'], 'Interstellar');
      expect(json['poster_path'], '/path.jpg');
      expect(json['vote_average'], 8.7);
    });
  });
}
