import '../../repositories/movie_repository.dart';

class GetMovieCrewUseCase {
  final MovieRepository movieRepository;

  GetMovieCrewUseCase(this.movieRepository);

  Future<dynamic> call(String movieId) {
    return movieRepository.getMovieCrew(movieId);
  }
}
