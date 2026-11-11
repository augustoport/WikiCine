import '../../core/shared/env.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.avatar,
    required super.sessionId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String sessionId) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username']?.toString(),
      name: json['name']?.toString() ?? json['username']?.toString(),
      avatar: json['avatar'] is Map ? AvatarModel.fromJson(json['avatar']) : null,
      sessionId: sessionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'avatar': avatar != null
          ? AvatarModel(
              gravatar: avatar!.gravatar,
              tmdb: avatar!.tmdb,
            ).toJson()
          : null,
      'sessionId': sessionId,
    };
  }
}

class AvatarModel extends Avatar {
  AvatarModel({required super.gravatar, required super.tmdb});

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    final gravatarMap = json['gravatar'] is Map ? json['gravatar'] : null;
    final tmdbMap = json['tmdb'] is Map ? json['tmdb'] : null;

    final gravatarHash = gravatarMap?['hash']?.toString();
    final tmdbPath = tmdbMap?['avatar_path']?.toString();

    return AvatarModel(
      gravatar: gravatarHash != null && gravatarHash.isNotEmpty
          ? Environment.production.mediaUrl + gravatarHash
          : '',
      tmdb: tmdbPath != null && tmdbPath.isNotEmpty
          ? Environment.production.mediaUrl + tmdbPath
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'gravatar': gravatar, 'tmdb': tmdb};
  }
}
