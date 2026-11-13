import '../../entities/credits.dart';
import '../../repositories/movie_repository.dart';

class GetMovieCrewUseCase {
  final MovieRepository movieRepository;

  GetMovieCrewUseCase(this.movieRepository);

  /// Retorna o elenco (apenas atores, departamento "Acting") e o diretor.
  Future<Credits> call(String movieId) async {
    final credits = await movieRepository.getMovieCredits(movieId);
    return Credits(
      cast: credits.cast.where((c) => c.department == 'Acting').toList(),
      director: credits.director,
    );
  }
}
