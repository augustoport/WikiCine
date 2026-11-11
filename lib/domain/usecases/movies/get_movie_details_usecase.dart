import '../../repositories/movie_repository.dart';

class GetMovieDetailsUseCase {
  final MovieRepository movieRepository;

  GetMovieDetailsUseCase(this.movieRepository);

  Future<dynamic> call(String movieId) {
    return movieRepository.getMovieDetailsFull(movieId);
  }
}
