import 'package:cinerating/domain/entities/credits.dart';
import 'package:cinerating/domain/entities/movie.dart';
import 'package:cinerating/domain/entities/tv_show.dart';
import 'package:cinerating/domain/entities/user.dart';
import 'package:cinerating/domain/repositories/auth_repository.dart';
import 'package:cinerating/domain/repositories/movie_repository.dart';
import 'package:cinerating/domain/repositories/tv_repository.dart';
import 'package:cinerating/domain/repositories/user_repository.dart';

import 'fixtures.dart';

/// Base dos repositórios falsos: registra as chamadas recebidas e permite
/// forçar falhas por nome de método (ex.: `repo.failing.add('getMovies')`).
abstract class _FakeRepository {
  /// Chamadas no formato `metodo` ou `metodo:argumento`.
  final List<String> calls = [];

  /// Métodos que devem lançar [FakeRepositoryException].
  final Set<String> failing = {};

  /// Latência simulada de cada chamada (útil para ver estados de loading).
  Duration delay = Duration.zero;

  Future<void> record(String method, [Object? arg]) async {
    calls.add(arg == null ? method : '$method:$arg');
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (failing.contains(method)) throw FakeRepositoryException(method);
  }
}

class FakeRepositoryException implements Exception {
  FakeRepositoryException(this.method);
  final String method;

  @override
  String toString() => 'FakeRepositoryException($method)';
}

class FakeAuthRepository extends _FakeRepository implements AuthRepository {
  /// Usuário devolvido por `login` quando as credenciais batem.
  User loginUser = Fixtures.user;

  /// Credenciais aceitas por `login`; qualquer outra lança exceção.
  String validUsername = 'cinefilo';
  String validPassword = '123456';

  /// Sessão já existente (retorno de `getCurrentUser`).
  User? currentUser;

  @override
  Future<User> login({required String username, required String password}) async {
    await record('login', username);
    if (username != validUsername || password != validPassword) {
      throw FakeRepositoryException('login');
    }
    currentUser = loginUser;
    return loginUser;
  }

  @override
  Future<User?> getCurrentUser() async {
    await record('getCurrentUser');
    return currentUser;
  }

  @override
  Future<void> logout() async {
    await record('logout');
    currentUser = null;
  }
}

class FakeMovieRepository extends _FakeRepository implements MovieRepository {
  List<Movie> movies = Fixtures.movies;
  List<Movie> searchResult = [Fixtures.movieB];
  Credits credits = Fixtures.credits;

  /// Detalhes por id; se ausente, procura em [movies].
  Map<String, Movie> details = {};

  @override
  Future<List<Movie>> getMovies() async {
    await record('getMovies');
    return movies;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    await record('searchMovies', query);
    return searchResult;
  }

  @override
  Future<Movie> getMovieDetails(String movieId) async {
    await record('getMovieDetails', movieId);
    return details[movieId] ?? movies.firstWhere((m) => m.id.toString() == movieId);
  }

  @override
  Future<Credits> getMovieCredits(String movieId) async {
    await record('getMovieCredits', movieId);
    return credits;
  }
}

class FakeTvRepository extends _FakeRepository implements TvRepository {
  List<TvShow> tvShows = Fixtures.tvShows;
  List<TvShow> searchResult = [Fixtures.tvB];
  Credits credits = const Credits(cast: [Fixtures.actor]);

  @override
  Future<List<TvShow>> getTvShows() async {
    await record('getTvShows');
    return tvShows;
  }

  @override
  Future<List<TvShow>> searchTvShows(String query) async {
    await record('searchTvShows', query);
    return searchResult;
  }

  @override
  Future<TvShow> getTvShowDetails(String tvShowId) async {
    await record('getTvShowDetails', tvShowId);
    return tvShows.firstWhere((t) => t.id.toString() == tvShowId);
  }

  @override
  Future<Credits> getTvShowCredits(String tvShowId) async {
    await record('getTvShowCredits', tvShowId);
    return credits;
  }
}

class FakeUserRepository extends _FakeRepository implements UserRepository {
  List<Movie> favorites = [Fixtures.movieA];

  @override
  Future<List<Movie>> getUserMovieFavorites() async {
    await record('getUserMovieFavorites');
    return favorites;
  }
}
