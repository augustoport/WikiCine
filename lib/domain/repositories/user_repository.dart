import '../entities/movie.dart';

abstract class UserRepository {
  Future<List<Movie>> getUserMovieFavorites();

  /// Adiciona ([favorite] = `true`) ou remove ([favorite] = `false`) o filme
  /// [movieId] dos favoritos da conta do usuário logado.
  Future<void> setMovieFavorite(int movieId, {required bool favorite});
}
