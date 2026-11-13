part of 'home_cubit.dart';

abstract class HomeStates {}

class HomeInitial extends HomeStates {}

class HomeLoading extends HomeStates {}

class HomeMovie extends HomeStates {
  HomeMovie(this.movies);

  final List<Movie>? movies;
}

class HomeTv extends HomeStates {
  HomeTv(this.tvShows);

  final List<TvShow>? tvShows;
}

class HomeError extends HomeStates {
  HomeError(this.message);

  final String message;
}
