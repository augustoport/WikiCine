import '../../../domain/entities/movie.dart';

abstract class ProfileStates {}

class ProfileInitial extends ProfileStates {}

class ProfileLoading extends ProfileStates {}

class ProfileSuccess extends ProfileStates {
  final List<Movie> favorites;
  final List<Movie> watchlist;

  ProfileSuccess({required this.favorites, required this.watchlist});
}

class ProfileError extends ProfileStates {}

/// Perfil acessado sem sessão de conta (visitante): a página volta à Home.
class ProfileRestricted extends ProfileStates {}
