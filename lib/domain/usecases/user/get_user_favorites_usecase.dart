import '../../entities/movie.dart';
import '../../repositories/user_repository.dart';

class GetUserFavoritesUseCase {
  final UserRepository userRepository;

  GetUserFavoritesUseCase(this.userRepository);

  Future<List<Movie>> call() {
    return userRepository.getUserMovieFavorites();
  }
}
