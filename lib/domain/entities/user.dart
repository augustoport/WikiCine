import 'package:cinerating/domain/entities/movie.dart';

class User {
  final int? id;
  final String? username;
  final String? name;
  final Avatar? avatar;
  final String? sessionId;
  final List<Movie?>? favoriteMovies;

  User({
    this.id,
    this.username,
    this.name,
    this.avatar,
    this.sessionId,
    this.favoriteMovies,
  });
}

class Avatar {
  final String gravatar;
  final String tmdb;

  Avatar({required this.gravatar, required this.tmdb});
}
