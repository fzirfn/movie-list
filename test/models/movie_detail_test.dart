import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browser/models/movie_detail.dart';

void main() {
  group('MovieDetail Model Tests', () {
    test(
      'MovieDetail.fromJson parses complete data including genres and cast',
      () {
        final json = {
          'id': 550,
          'title': 'Fight Club',
          'poster_path': '/poster.jpg',
          'backdrop_path': '/backdrop.jpg',
          'vote_average': 8.4,
          'release_date': '1999-10-15',
          'overview': 'An insomniac office worker...',
          'runtime': 139,
          'genres': [
            {'id': 18, 'name': 'Drama'},
            {'id': 53, 'name': 'Thriller'},
          ],
          'credits': {
            'cast': [
              {
                'id': 819,
                'name': 'Edward Norton',
                'character': 'The Narrator',
                'profile_path': '/edward.jpg',
              },
              {
                'id': 287,
                'name': 'Brad Pitt',
                'character': 'Tyler Durden',
                'profile_path': '/brad.jpg',
              },
            ],
          },
        };

        final detail = MovieDetail.fromJson(json);

        expect(detail.id, 550);
        expect(detail.title, 'Fight Club');
        expect(detail.runtime, 139);
        expect(detail.runtimeFormatted, '2h 19m');
        expect(detail.releaseYear, '1999');
        expect(detail.genres, ['Drama', 'Thriller']);
        expect(detail.cast.length, 2);
        expect(detail.cast[0].name, 'Edward Norton');
        expect(detail.cast[0].character, 'The Narrator');
        expect(detail.cast[1].name, 'Brad Pitt');
      },
    );

    test('MovieDetail.fromJson limits cast to top 10', () {
      final json = {
        'id': 1,
        'title': 'Big Cast Movie',
        'credits': {
          'cast': List.generate(
            20,
            (i) => {'id': i, 'name': 'Actor $i', 'character': 'Role $i'},
          ),
        },
      };

      final detail = MovieDetail.fromJson(json);
      expect(detail.cast.length, 10);
      expect(detail.cast.first.name, 'Actor 0');
      expect(detail.cast.last.name, 'Actor 9');
    });

    test('toMovie converts MovieDetail to Movie instance correctly', () {
      final detail = MovieDetail.fromJson({
        'id': 42,
        'title': 'The Answer',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 7.8,
        'release_date': '2005-04-28',
        'overview': 'Don\'t panic.',
      });

      final movie = detail.toMovie();

      expect(movie.id, 42);
      expect(movie.title, 'The Answer');
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.backdropPath, '/backdrop.jpg');
      expect(movie.voteAverage, 7.8);
      expect(movie.releaseDate, '2005-04-28');
      expect(movie.overview, 'Don\'t panic.');
    });

    test('fromMovie converts Movie to preliminary MovieDetail correctly', () {
      final detail = MovieDetail.fromJson({
        'id': 42,
        'title': 'The Answer',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 7.8,
        'release_date': '2005-04-28',
        'overview': 'Don\'t panic.',
      });
      final movie = detail.toMovie();
      final preliminaryDetail = MovieDetail.fromMovie(movie);

      expect(preliminaryDetail.id, 42);
      expect(preliminaryDetail.title, 'The Answer');
      expect(preliminaryDetail.posterPath, '/poster.jpg');
      expect(preliminaryDetail.backdropPath, '/backdrop.jpg');
      expect(preliminaryDetail.voteAverage, 7.8);
      expect(preliminaryDetail.releaseDate, '2005-04-28');
      expect(preliminaryDetail.overview, 'Don\'t panic.');
      expect(preliminaryDetail.genres, isEmpty);
      expect(preliminaryDetail.cast, isEmpty);
      expect(preliminaryDetail.runtime, isNull);
    });
  });
}
