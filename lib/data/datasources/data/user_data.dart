import '../../../domain/entities/movie.dart';

abstract class UserData {
  Future<List<Movie>> getFavoriteMovies();
  Future<void> setFavoriteMovie(int movieId, {required bool favorite});
}
