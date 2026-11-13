class User {
  final int? id;
  final String? username;
  final String? name;
  final Avatar? avatar;
  final String? sessionId;

  User({this.id, this.username, this.name, this.avatar, this.sessionId});
}

class Avatar {
  final String gravatar;
  final String tmdb;

  Avatar({required this.gravatar, required this.tmdb});
}
