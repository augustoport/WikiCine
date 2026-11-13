import '../../../domain/entities/credits.dart';
import '../../../domain/entities/movie.dart';

abstract class MovieData {
  Future<List<Movie>> getMovies();
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> getMovieDetails(String movieId);
  Future<Credits> getMovieCredits(String movieId);
}
