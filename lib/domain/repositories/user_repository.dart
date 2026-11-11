import '../entities/movie.dart';

abstract class UserRepository {
  Future<List<Movie>> getUserMovieFavorites();
}

