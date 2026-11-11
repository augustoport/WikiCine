import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/data/movie_data.dart';

class MovieApi implements MovieRepository {
  final MovieData movieData;

  MovieApi({required this.movieData});

  @override
  Future<List<Movie>> getMovies() {
    return movieData.getMovies();
  }

  @override
  Future<List<Movie>> searchMovies(String query) {
    return movieData.searchMovies(query);
  }

  @override
  Future<Movie> getMovieDetails(String movieId) {
    return movieData.getMovieDetails(movieId);
  }

  @override
  Future<dynamic> getMovieCrew(String movieId) {
    return movieData.getMovieCrew(movieId);
  }

  @override
  Future<dynamic> getMovieDetailsFull(String movieId) {
    return movieData.getMovieDetailsFull(movieId);
  }

  @override
  Future<List<Movie>> getFavoriteMovies() {
    return movieData.getFavoriteMovies();
  }
}
