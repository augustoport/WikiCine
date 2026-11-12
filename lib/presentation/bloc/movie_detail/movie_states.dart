part of 'movie_cubit.dart';

abstract class MovieStates {}

class MovieInitial extends MovieStates {}

class MovieLoading extends MovieStates {}

class MovieSuccess extends MovieStates {
  final Movie movieDetail;
  final List<CrewModel> cast;
  final CrewModel director;
  final bool isFavorite;

  MovieSuccess(this.movieDetail, this.cast, this.director, this.isFavorite);
}

class MovieError extends MovieStates {
  final String message;
  MovieError({this.message = "Não foi possível carregar os detalhes do filme"});
}
