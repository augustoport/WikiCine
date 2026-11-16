part of 'movie_cubit.dart';

abstract class MovieStates {}

class MovieInitial extends MovieStates {}

class MovieLoading extends MovieStates {}

class MovieSuccess extends MovieStates {
  final Movie movieDetail;
  final List<CastMember> cast;
  final CastMember? director;

  /// `false` para visitante (guest): o botão de favorito não é exibido.
  final bool canFavorite;

  MovieSuccess(
    this.movieDetail,
    this.cast,
    this.director, {
    required this.canFavorite,
  });
}

class MovieError extends MovieStates {
  final String message;
  MovieError({this.message = "Não foi possível carregar os detalhes do filme"});
}

/// Resultado de [MovieCubit.toggleFavorite], usado pela página para o toast.
enum FavoriteResult { added, removed, addFailed, removeFailed }
