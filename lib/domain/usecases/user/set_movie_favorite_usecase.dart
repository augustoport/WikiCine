import '../../repositories/user_repository.dart';

/// Adiciona ou remove um filme dos favoritos do usuário logado.
class SetMovieFavoriteUseCase {
  final UserRepository userRepository;

  SetMovieFavoriteUseCase(this.userRepository);

  Future<void> call(int movieId, {required bool favorite}) {
    return userRepository.setMovieFavorite(movieId, favorite: favorite);
  }
}
