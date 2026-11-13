import 'package:cinerating/domain/entities/credits.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_crew_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_details_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movies_usecase.dart';
import 'package:cinerating/domain/usecases/movies/search_movies_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeMovieRepository repository;

  setUp(() => repository = FakeMovieRepository());

  group('GetMoviesUseCase', () {
    test('retorna a lista de filmes do repositório', () async {
      final movies = await GetMoviesUseCase(repository)();

      expect(movies, Fixtures.movies);
      expect(repository.calls, ['getMovies']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getMovies');

      expect(GetMoviesUseCase(repository).call, throwsA(isA<FakeRepositoryException>()));
    });
  });

  group('SearchMoviesUseCase', () {
    test('repassa o termo de busca e retorna o resultado', () async {
      final result = await SearchMoviesUseCase(repository)('cidade');

      expect(result, [Fixtures.movieB]);
      expect(repository.calls, ['searchMovies:cidade']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('searchMovies');

      expect(
        () => SearchMoviesUseCase(repository)('x'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('GetMovieDetailsUseCase', () {
    test('busca os detalhes pelo id', () async {
      final movie = await GetMovieDetailsUseCase(repository)('1');

      expect(movie, same(Fixtures.movieA));
      expect(repository.calls, ['getMovieDetails:1']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getMovieDetails');

      expect(
        () => GetMovieDetailsUseCase(repository)('1'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('GetMovieCrewUseCase', () {
    test('mantém apenas atores (departamento "Acting") no elenco', () async {
      final credits = await GetMovieCrewUseCase(repository)('1');

      expect(credits.cast, [Fixtures.actor]);
      expect(credits.cast.every((c) => c.department == 'Acting'), isTrue);
      expect(repository.calls, ['getMovieCredits:1']);
    });

    test('preserva o diretor retornado pelo repositório', () async {
      final credits = await GetMovieCrewUseCase(repository)('1');

      expect(credits.director, same(Fixtures.director));
    });

    test('retorna elenco vazio e sem diretor quando não há créditos', () async {
      repository.credits = const Credits();

      final credits = await GetMovieCrewUseCase(repository)('1');

      expect(credits.cast, isEmpty);
      expect(credits.director, isNull);
    });

    test('descarta membros sem departamento', () async {
      repository.credits = const Credits(
        cast: [CastMember(name: 'Sem departamento'), Fixtures.actor],
      );

      final credits = await GetMovieCrewUseCase(repository)('1');

      expect(credits.cast.map((c) => c.name), ['Matthew McConaughey']);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getMovieCredits');

      expect(
        () => GetMovieCrewUseCase(repository)('1'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });
}
