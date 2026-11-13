import 'package:bloc/bloc.dart';

import '../../../domain/entities/credits.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/movies/get_movie_crew_usecase.dart';
import '../../../domain/usecases/movies/get_movie_details_usecase.dart';
import '../../../domain/usecases/user/get_user_favorites_usecase.dart';

part 'movie_states.dart';

class MovieCubit extends Cubit<MovieStates> {
  MovieCubit({
    required GetMovieDetailsUseCase getMovieDetailsUseCase,
    required GetMovieCrewUseCase getMovieCrewUseCase,
    required GetUserFavoritesUseCase getUserFavoritesUseCase,
  }) : _getMovieDetailsUseCase = getMovieDetailsUseCase,
       _getMovieCrewUseCase = getMovieCrewUseCase,
       _getUserFavoritesUseCase = getUserFavoritesUseCase,
       super(MovieInitial());

  final GetMovieDetailsUseCase _getMovieDetailsUseCase;
  final GetMovieCrewUseCase _getMovieCrewUseCase;
  final GetUserFavoritesUseCase _getUserFavoritesUseCase;

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

  Future<bool> _isFavorite(Movie movie) async {
    try {
      final favorites = await _getUserFavoritesUseCase();
      return favorites.any((f) => f.id == movie.id);
    } catch (_) {
      return false;
    }
  }
}
