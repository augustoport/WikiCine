import '../../entities/movie.dart';
import '../../repositories/movie_repository.dart';

class SearchMoviesUseCase {
  final MovieRepository movieRepository;

  SearchMoviesUseCase(this.movieRepository);

  Future<List<Movie>> call(String query) {
    return movieRepository.searchMovies(query);
  }
}
