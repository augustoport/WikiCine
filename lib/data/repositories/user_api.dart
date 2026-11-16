import '../../domain/entities/movie.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/data/user_data.dart';

class UserApi implements UserRepository {
  final UserData userData;

  UserApi(this.userData);

  @override
  Future<List<Movie>> getUserMovieFavorites() => userData.getFavoriteMovies();

  @override
  Future<void> setMovieFavorite(int movieId, {required bool favorite}) =>
      userData.setFavoriteMovie(movieId, favorite: favorite);
}
