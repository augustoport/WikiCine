import 'package:dio/dio.dart';

import '../../../core/shared/env.dart';
import '../../../domain/entities/credits.dart';
import '../../../domain/entities/tv_show.dart';
import '../../models/movie_simple_model.dart';
import '../../models/tv_crew_model.dart';
import '../../models/tv_show_model.dart';
import '../data/tv_data.dart';

class TvImplementation implements TvData {
  final Dio _dio = Dio();

  TvImplementation() {
    _dio.options.headers["Authorization"] =
        "Bearer ${Environment.production.token}";
    _dio.options.baseUrl = Environment.production.baseUrl;
  }

  @override
  Future<List<TvShow>> getTvShows() async {
    final response = await _dio.get('/discover/tv');
    return (response.data['results'] as List)
        .map((json) => _mapToEntity(MovieSimpleModel.fromMap(json)))
        .toList();
  }

  @override
  Future<List<TvShow>> searchTvShows(String query) async {
    final response = await _dio.get(
      '/search/tv',
      queryParameters: {'query': query, 'language': 'en-US;pt-BR'},
    );
    return (response.data['results'] as List)
        .map((json) => _mapToEntity(MovieSimpleModel.fromMap(json)))
        .toList();
  }

  @override
  Future<TvShow> getTvShowDetails(String tvShowId) async {
    final response = await _dio.get('/tv/$tvShowId');
    return TvShowModel.fromMap(response.data);
  }

  @override
  Future<Credits> getTvShowCredits(String tvShowId) async {
    final response = await _dio.get('/tv/$tvShowId/aggregate_credits');
    return TvShowCrew.fromMap(response.data).toEntity();
  }

  TvShow _mapToEntity(MovieSimpleModel model) {
    return TvShow(
      id: model.id ?? 0,
      name: model.name,
      overview: model.overview,
      posterPath: model.posterPath,
      backdropPath: model.backdropPath,
      voteAverage: model.voteAverage,
      voteCount: model.voteCount,
      firstAirDate: model.releaseDate,
      genreIds: model.genreIds,
    );
  }
}
