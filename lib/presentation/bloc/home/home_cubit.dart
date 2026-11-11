import 'package:bloc/bloc.dart';
import 'package:cinerating/core/locator.dart';
import 'package:cinerating/domain/entities/movie.dart';
import 'package:cinerating/domain/entities/tv_show.dart';
import 'package:cinerating/domain/usecases/movies/get_movies_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_shows_usecase.dart';
import 'package:cinerating/domain/usecases/movies/search_movies_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/search_tv_shows_usecase.dart';

part 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitial()) {
    _getMoviesUseCase = getIt<GetMoviesUseCase>();
    _searchMoviesUseCase = getIt<SearchMoviesUseCase>();
    _getTvShowsUseCase = getIt<GetTvShowsUseCase>();
    _searchTvShowsUseCase = getIt<SearchTvShowsUseCase>();
  }

  late final GetMoviesUseCase _getMoviesUseCase;
  late final SearchMoviesUseCase _searchMoviesUseCase;
  late final GetTvShowsUseCase _getTvShowsUseCase;
  late final SearchTvShowsUseCase _searchTvShowsUseCase;

  Future<void> getMovies() async {
    emit(HomeLoading());
    try {
      final movies = await _getMoviesUseCase();
      emit(HomeMovie(movies));
    } catch (e) {
      emit(HomeError('Não foi possível carregar os filmes'));
    }
  }

  Future<void> getMovie(String? movie) async {
    emit(HomeLoading());
    try {
      if (movie != null && movie != "") {
        final movies = await _searchMoviesUseCase(movie);
        emit(HomeMovie(movies));
      } else {
        getMovies();
      }
    } catch (e) {
      emit(HomeError("Não foi possivel buscar o filme"));
    }
  }

  Future<void> getTvShows() async {
    emit(HomeLoading());
    try {
      final tvShows = await _getTvShowsUseCase();
      emit(HomeTv(tvShows));
    } catch (e) {
      emit(HomeError('Não foi possível carregar os programas de TV'));
    }
  }

  Future<void> getTvShow(String? show) async {
    emit(HomeLoading());
    try {
      if (show != null && show != "") {
        final tvShows = await _searchTvShowsUseCase(show);
        emit(HomeTv(tvShows));
      } else {
        getTvShows();
      }
    } catch (e) {
      emit(HomeError("Não foi possivel buscar o programa de TV"));
    }
  }
}
