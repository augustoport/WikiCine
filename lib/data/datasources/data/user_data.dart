import '../../../domain/entities/movie.dart';

abstract class UserData {
  Future<List<Movie>> getFavoriteMovies();
}
