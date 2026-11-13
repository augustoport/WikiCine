import 'genre.dart';

class Movie {
  final int? id;
  final int? runtime;
  final String? title;
  final String? name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final DateTime? releaseDate;
  final List<int>? genreIds;
  final List<Genre>? genres;

  Movie({
    this.id,
    this.runtime,
    this.title,
    this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.genreIds,
    this.genres,
  });
}
