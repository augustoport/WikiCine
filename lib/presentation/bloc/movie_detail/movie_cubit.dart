import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/credits.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/auth/is_logged_in_usecase.dart';
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
    required IsLoggedInUseCase isLoggedInUseCase,
  }) : _getMovieDetailsUseCase = getMovieDetailsUseCase,
       _getMovieCrewUseCase = getMovieCrewUseCase,
       _getUserFavoritesUseCase = getUserFavoritesUseCase,
       _setMovieFavoriteUseCase = setMovieFavoriteUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       super(MovieInitial());

  final GetMovieDetailsUseCase _getMovieDetailsUseCase;
  final GetMovieCrewUseCase _getMovieCrewUseCase;
  final GetUserFavoritesUseCase _getUserFavoritesUseCase;
  final SetMovieFavoriteUseCase _setMovieFavoriteUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;

  /// Se o filme exibido está nos favoritos. O botão de favorito escuta este
  /// valor com um `ListenableBuilder`, então favoritar não recarrega a tela.
  final ValueNotifier<bool> isFavorite = ValueNotifier(false);

  bool _updatingFavorite = false;

  Future<void> getMovieDetails(String movieId) async {
    emit(MovieLoading());
    try {
      final movie = await _getMovieDetailsUseCase(movieId);
      final credits = await _getMovieCrewUseCase(movieId);
      final loggedIn = await _isLoggedIn();
      isFavorite.value = loggedIn && await _isInFavorites(movie);
      emit(MovieSuccess(movie, credits.cast, credits.director, canFavorite: loggedIn));
    } catch (e) {
      emit(MovieError());
    }
  }

  /// Inverte o favorito do filme exibido.
  ///
  /// Não favorito → adiciona; favorito → remove. Em caso de sucesso,
  /// [isFavorite] recebe o novo valor; em caso de falha, fica como estava.
  /// Retorna `null` quando não há ação possível (tela sem filme, visitante
  /// ou outra atualização em andamento).
  Future<FavoriteResult?> toggleFavorite() async {
    final current = state;
    if (current is! MovieSuccess || !current.canFavorite) return null;
    final movieId = current.movieDetail.id;
    if (movieId == null || _updatingFavorite) return null;

    final add = !isFavorite.value;
    _updatingFavorite = true;
    try {
      await _setMovieFavoriteUseCase(movieId, favorite: add);
      isFavorite.value = add;
      return add ? FavoriteResult.added : FavoriteResult.removed;
    } catch (_) {
      return add ? FavoriteResult.addFailed : FavoriteResult.removeFailed;
    } finally {
      _updatingFavorite = false;
    }
  }

  Future<bool> _isLoggedIn() async {
    try {
      return await _isLoggedInUseCase();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isInFavorites(Movie movie) async {
    try {
      final favorites = await _getUserFavoritesUseCase();
      return favorites.any((f) => f.id == movie.id);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    isFavorite.dispose();
    return super.close();
  }
}
