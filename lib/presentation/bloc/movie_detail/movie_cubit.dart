import 'package:bloc/bloc.dart';

import '../../../domain/entities/credits.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/movies/get_movie_crew_usecase.dart';
import '../../../domain/usecases/movies/get_movie_details_usecase.dart';
import '../../../domain/usecases/user/get_user_favorites_usecase.dart';
import '../../../domain/usecases/user/set_movie_favorite_usecase.dart';

part 'movie_states.dart';

class MovieCubit extends Cubit<MovieStates> {
  MovieCubit({
    required GetMovieDetailsUseCase getMovieDetailsUseCase,
    required GetMovieCrewUseCase getMovieCrewUseCase,
    required GetUserFavoritesUseCase getUserFavoritesUseCase,
    required SetMovieFavoriteUseCase setMovieFavoriteUseCase,
  }) : _getMovieDetailsUseCase = getMovieDetailsUseCase,
       _getMovieCrewUseCase = getMovieCrewUseCase,
       _getUserFavoritesUseCase = getUserFavoritesUseCase,
       _setMovieFavoriteUseCase = setMovieFavoriteUseCase,
       super(MovieInitial());

  final GetMovieDetailsUseCase _getMovieDetailsUseCase;
  final GetMovieCrewUseCase _getMovieCrewUseCase;
  final GetUserFavoritesUseCase _getUserFavoritesUseCase;
  final SetMovieFavoriteUseCase _setMovieFavoriteUseCase;

  Future<void> getMovieDetails(String movieId) async {
    emit(MovieLoading());
    try {
      final movie = await _getMovieDetailsUseCase(movieId);
      final credits = await _getMovieCrewUseCase(movieId);
      final isFavorite = await _isFavorite(movie);
      emit(MovieSuccess(movie, credits.cast, credits.director, isFavorite));
    } catch (e) {
      emit(MovieError());
    }
  }

  /// Inverte o favorito do filme exibido e recarrega a tela.
  ///
  /// Não favorito → adiciona; favorito → remove. Em seguida chama
  /// [getMovieDetails] de novo, que relê os favoritos e atualiza o ícone.
  /// Se a chamada falhar, o recarregamento mostra o estado real da conta.
  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! MovieSuccess) return;
    final movieId = current.movieDetail.id;
    if (movieId == null) return;

    try {
      await _setMovieFavoriteUseCase(movieId, favorite: !current.isFavorite);
    } catch (_) {
      // Sem tratamento de falha tipada ainda (D31): o recarregamento abaixo
      // mantém o ícone coerente com o que está salvo no TMDB.
    }
    await getMovieDetails(movieId.toString());
  }

  Future<bool> _isFavorite(Movie movie) async {
    try {
      final favorites = await _getUserFavoritesUseCase();
      return favorites.any((f) => f.id == movie.id);
    } catch (_) {
      return false;
    }
  }
}
