part of 'serie_cubit.dart';

abstract class SerieState {}

class SerieInitial extends SerieState {}

class SerieLoading extends SerieState {}

class SerieSuccess extends SerieState {
  SerieSuccess(this.tvShow, this.cast);

  final TvShow tvShow;
  final List<CastMember> cast;
}

class SerieError extends SerieState {}
