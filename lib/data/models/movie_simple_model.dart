import 'dart:convert';

import '../../core/shared/env.dart';
import '../../domain/entities/movie.dart';

class MovieSimpleModel extends Movie {
  bool? adult;
  String? originalLanguage;
  String? originalTitle;
  double? popularity;
  bool? video;

  MovieSimpleModel({
    super.backdropPath,
    super.genreIds,
    super.id,
    super.overview,
    super.posterPath,
    super.releaseDate,
    super.title,
    super.name,
    super.voteAverage,
    this.adult,
    this.originalLanguage,
    this.originalTitle,
    this.popularity,
    this.video,
    super.voteCount,
  });

  MovieSimpleModel copyWith({
    bool? adult,
    String? backdropPath,
    List<int>? genreIds,
    int? id,
    String? originalLanguage,
    String? originalTitle,
    String? overview,
    double? popularity,
    String? posterPath,
    DateTime? releaseDate,
    String? title,
    String? name,
    bool? video,
    double? voteAverage,
    int? voteCount,
  }) => MovieSimpleModel(
    adult: adult ?? this.adult,
    backdropPath: backdropPath ?? this.backdropPath,
    genreIds: genreIds ?? this.genreIds,
    id: id ?? this.id,
    originalLanguage: originalLanguage ?? this.originalLanguage,
    originalTitle: originalTitle ?? this.originalTitle,
    overview: overview ?? this.overview,
    popularity: popularity ?? this.popularity,
    posterPath: posterPath ?? this.posterPath,
    releaseDate: releaseDate ?? this.releaseDate,
    title: title ?? this.title,
    name: name ?? this.name,
    video: video ?? this.video,
    voteAverage: voteAverage ?? this.voteAverage,
    voteCount: voteCount ?? this.voteCount,
  );

  factory MovieSimpleModel.fromJson(String str) =>
      MovieSimpleModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MovieSimpleModel.fromMap(Map<String, dynamic> json) =>
      MovieSimpleModel(
        adult: json["adult"],
        backdropPath: json["backdrop_path"] == null
            ? null
            : Environment.production.mediaUrl + json["backdrop_path"],
        genreIds: json["genre_ids"] == null
            ? []
            : List<int>.from(json["genre_ids"]!.map((x) => x)),
        id: json["id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"] == null
            ? null
            : Environment.production.mediaUrl + json["poster_path"],
        releaseDate: json["release_date"] == null || json["release_date"] == ""
            ? null
            : DateTime.parse(json["release_date"]),
        title: json["title"],
        name: json["name"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toMap() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "genre_ids": genreIds == null
        ? []
        : List<dynamic>.from(genreIds!.map((x) => x)),
    "id": id,
    "original_language": originalLanguage,
    "original_title": originalTitle,
    "overview": overview,
    "popularity": popularity,
    "poster_path": posterPath,
    "release_date":
        "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}",
    "title": title,
    "name": name,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}
