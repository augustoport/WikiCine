import 'package:cinerating/domain/repositories/movie_repository.dart';

import '../../entities/movie.dart';

class GetUserFavoritesUsecases {
  final MovieRepository movieRepository;

  GetUserFavoritesUsecases(this.movieRepository);

  Future<List<Movie>> call() {
    return movieRepository.getFavoriteMovies();
  }
}
