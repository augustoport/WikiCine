import 'genre.dart';

class TvShow {
  final int? id;
  final String? name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final DateTime? firstAirDate;
  final List<int>? genreIds;
  final List<Genre>? genres;

  TvShow({
    required this.id,
    this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.firstAirDate,
    this.genreIds,
    this.genres,
  });
}
