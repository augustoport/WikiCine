import 'package:dio/dio.dart';

import '../../../core/shared/env.dart';
import '../../../domain/entities/credits.dart';
import '../../../domain/entities/movie.dart';
import '../../models/crew_model.dart';
import '../../models/movie_detail_model.dart';
import '../../models/movie_simple_model.dart';
import '../data/movie_data.dart';

class MovieImplementation implements MovieData {
  final Dio _dio = Dio();

  MovieImplementation() {
    _dio.options.headers["Authorization"] =
        "Bearer ${Environment.production.token}";
    _dio.options.baseUrl = Environment.production.baseUrl;
  }

  @override
  Future<List<Movie>> getMovies() async {
    final response = await _dio.get('/discover/movie');
    return (response.data['results'] as List)
        .map((m) => MovieSimpleModel.fromMap(m))
        .toList();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {'query': query, 'language': 'en-US;pt-BR'},
    );
    return (response.data['results'] as List)
        .map((m) => MovieSimpleModel.fromMap(m))
        .toList();
  }

  @override
  Future<Movie> getMovieDetails(String movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return MovieDetailModel.fromMap(response.data);
  }

  @override
  Future<Credits> getMovieCredits(String movieId) async {
    final response = await _dio.get('/movie/$movieId/credits');

    final cast = (response.data['cast'] as List? ?? [])
        .map((c) => CrewModel.fromMap(c).toEntity())
        .toList();

    final crew = (response.data['crew'] as List? ?? [])
        .map((c) => CrewModel.fromMap(c).toEntity());

    final directors = crew.where((c) => c.job == 'Director');

    return Credits(
      cast: cast,
      director: directors.isEmpty ? null : directors.first,
    );
  }
}
