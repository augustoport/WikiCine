import '../../../domain/entities/movie.dart';

abstract class MovieData {
  Future<List<Movie>> getMovies();
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> getMovieDetails(String movieId);
  Future<dynamic> getMovieCrew(String movieId);
  Future<dynamic> getMovieDetailsFull(String movieId);
  Future<List<Movie>> getFavoriteMovies();
}
