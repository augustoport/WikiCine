import '../../domain/entities/credits.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/data/movie_data.dart';

class MovieApi implements MovieRepository {
  final MovieData movieData;

  MovieApi(this.movieData);

  @override
  Future<List<Movie>> getMovies() => movieData.getMovies();

  @override
  Future<List<Movie>> searchMovies(String query) =>
      movieData.searchMovies(query);

  @override
  Future<Movie> getMovieDetails(String movieId) =>
      movieData.getMovieDetails(movieId);

  @override
  Future<Credits> getMovieCredits(String movieId) =>
      movieData.getMovieCredits(movieId);
}
