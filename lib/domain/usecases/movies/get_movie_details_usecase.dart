import '../../entities/movie.dart';
import '../../repositories/movie_repository.dart';

class GetMovieDetailsUseCase {
  final MovieRepository movieRepository;

  GetMovieDetailsUseCase(this.movieRepository);

  Future<Movie> call(String movieId) {
    return movieRepository.getMovieDetails(movieId);
  }
}
