import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/shared/env.dart';
import '../../../core/shared/storage_keys.dart';
import '../../../domain/entities/movie.dart';
import '../../models/movie_detail_model.dart';
import '../data/user_data.dart';

class UserImplementation implements UserData {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage;

  UserImplementation(this._storage) {
    _dio.options.headers["Authorization"] =
        "Bearer ${Environment.production.token}";
    _dio.options.baseUrl = Environment.production.baseUrl;
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    final id = await _storage.read(key: StorageKeys.accountId);
    final response = await _dio.get('/account/$id/favorite/movies');
    return (response.data['results'] as List)
        .map((m) => MovieDetailModel.fromMap(m))
        .toList();
  }

  /// `POST /account/{account_id}/favorite?session_id=...`
  ///
  /// O mesmo endpoint adiciona (`favorite: true`) ou remove (`favorite: false`).
  @override
  Future<void> setFavoriteMovie(int movieId, {required bool favorite}) async {
    final accountId = await _storage.read(key: StorageKeys.accountId);
    final sessionId = await _storage.read(key: StorageKeys.sessionId);
    await _dio.post(
      '/account/$accountId/favorite',
      queryParameters: {'session_id': sessionId},
      data: {'media_type': 'movie', 'media_id': movieId, 'favorite': favorite},
    );
  }
}
