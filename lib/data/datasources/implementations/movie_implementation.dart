import 'package:cinerating/data/models/movie_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/movie.dart';
import '../../models/movie_simple_model.dart';
import '../../../core/shared/env.dart';
import '../data/movie_data.dart';

class MovieImplementation implements MovieData {
  final Dio _dio = Dio();
  final _storage = FlutterSecureStorage();

  MovieImplementation() {
    _dio.options.headers["Authorization"] =
        "Bearer ${Environment.production.token}";
    _dio.options.baseUrl = Environment.production.baseUrl;
  }

  @override
  Future<List<Movie>> getMovies() async {
    final response = await _dio.get('/discover/movie');

    List<Movie> movieList = [];

    for (var m in (response.data['results'] as List)) {
      Movie movie = MovieSimpleModel.fromMap(m);
      movieList.add(movie);
    }

    return movieList;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {'query': query, 'language': 'en-US;pt-BR'},
    );

    List<Movie> movieList = [];

    for (var m in (response.data['results'] as List)) {
      Movie movie = MovieSimpleModel.fromMap(m);
      movieList.add(movie);
    }

    return movieList;
  }

  @override
  Future<Movie> getMovieDetails(String movieId) async {
    final response = await _dio.get('/movie/$movieId');
    Movie model = MovieDetailModel.fromMap(response.data);
    return model;
  }

  @override
  Future<dynamic> getMovieCrew(String movieId) async {
    final response = await _dio.get('/movie/$movieId/credits');
    return response.data;
  }

  @override
  Future<dynamic> getMovieDetailsFull(String movieId) async {
    final response = await _dio.get('/movie/$movieId');
    return response.data;
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    final id = await _storage.read(key: 'account_id');
    final response = await _dio.get('/account/$id/favorite/movies');

    List<Movie> movieList = [];

    for (var m in (response.data['results'] as List)) {
      final movie = MovieDetailModel.fromMap(m);
      movieList.add(movie);
    }

    
    return movieList;
  }
}
