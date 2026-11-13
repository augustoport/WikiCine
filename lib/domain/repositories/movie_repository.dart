import '../entities/credits.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getMovies();
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> getMovieDetails(String movieId);
  Future<Credits> getMovieCredits(String movieId);
}
