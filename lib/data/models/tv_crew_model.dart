import 'dart:convert';

import '../../core/shared/env.dart';
import '../../domain/entities/credits.dart';

class TvShowCrew {
  List<Cast>? cast;
  List<Cast>? crew;
  int? id;

  TvShowCrew({this.cast, this.crew, this.id});

  TvShowCrew copyWith({List<Cast>? cast, List<Cast>? crew, int? id}) =>
      TvShowCrew(
        cast: cast ?? this.cast,
        crew: crew ?? this.crew,
        id: id ?? this.id,
      );

  factory TvShowCrew.fromJson(String str) =>
      TvShowCrew.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TvShowCrew.fromMap(Map<String, dynamic> json) => TvShowCrew(
    cast: json["cast"] == null
        ? []
        : List<Cast>.from(json["cast"]!.map((x) => Cast.fromMap(x))),
    crew: json["crew"] == null
        ? []
        : List<Cast>.from(json["crew"]!.map((x) => Cast.fromMap(x))),
    id: json["id"],
  );

  Credits toEntity() =>
      Credits(cast: (cast ?? []).map((c) => c.toEntity()).toList());

  Map<String, dynamic> toMap() => {
    "cast": cast == null ? [] : List<dynamic>.from(cast!.map((x) => x.toMap())),
    "crew": crew == null ? [] : List<dynamic>.from(crew!.map((x) => x.toMap())),
    "id": id,
  };
}

class Cast {
  bool? adult;
  int? gender;
  int? id;
  String? knownForDepartment;
  String? name;
  String? originalName;
  double? popularity;
  String? profilePath;
  List<Role>? roles;
  int? totalEpisodeCount;
  int? order;
  List<Job>? jobs;
  String? department;

  Cast({
    this.adult,
    this.gender,
    this.id,
    this.knownForDepartment,
    this.name,
    this.originalName,
    this.popularity,
    this.profilePath,
    this.roles,
    this.totalEpisodeCount,
    this.order,
    this.jobs,
    this.department,
  });

  Cast copyWith({
    bool? adult,
    int? gender,
    int? id,
    String? knownForDepartment,
    String? name,
    String? originalName,
    double? popularity,
    String? profilePath,
    List<Role>? roles,
    int? totalEpisodeCount,
    int? order,
    List<Job>? jobs,
    String? department,
  }) => Cast(
    adult: adult ?? this.adult,
    gender: gender ?? this.gender,
    id: id ?? this.id,
    knownForDepartment: knownForDepartment ?? this.knownForDepartment,
    name: name ?? this.name,
    originalName: originalName ?? this.originalName,
    popularity: popularity ?? this.popularity,
    profilePath: profilePath ?? this.profilePath,
    roles: roles ?? this.roles,
    totalEpisodeCount: totalEpisodeCount ?? this.totalEpisodeCount,
    order: order ?? this.order,
    jobs: jobs ?? this.jobs,
    department: department ?? this.department,
  );

  factory Cast.fromJson(String str) => Cast.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Cast.fromMap(Map<String, dynamic> json) => Cast(
    adult: json["adult"],
    gender: json["gender"],
    id: json["id"],
    knownForDepartment: json["known_for_department"],
    name: json["name"],
    originalName: json["original_name"],
    popularity: json["popularity"]?.toDouble(),
    profilePath: json["profile_path"] == null
        ? null
        : Environment.production.mediaUrl + json["profile_path"],
    roles: json["roles"] == null
        ? []
        : List<Role>.from(json["roles"]!.map((x) => Role.fromMap(x))),
    totalEpisodeCount: json["total_episode_count"],
    order: json["order"],
    jobs: json["jobs"] == null
        ? []
        : List<Job>.from(json["jobs"]!.map((x) => Job.fromMap(x))),
    department: json["department"],
  );

  CastMember toEntity() => CastMember(
    id: id,
    name: name,
    character: (roles?.isNotEmpty ?? false) ? roles!.first.character : null,
    profilePath: profilePath,
    department: knownForDepartment,
    job: (jobs?.isNotEmpty ?? false) ? jobs!.first.job : null,
  );

  Map<String, dynamic> toMap() => {
    "adult": adult,
    "gender": gender,
    "id": id,
    "known_for_department": knownForDepartment,
    "name": name,
    "original_name": originalName,
    "popularity": popularity,
    "profile_path": profilePath,
    "roles": roles == null
        ? []
        : List<dynamic>.from(roles!.map((x) => x.toMap())),
    "total_episode_count": totalEpisodeCount,
    "order": order,
    "jobs": jobs == null ? [] : List<dynamic>.from(jobs!.map((x) => x.toMap())),
    "department": department,
  };
}

class Job {
  String? creditId;
  String? job;
  int? episodeCount;

  Job({this.creditId, this.job, this.episodeCount});

  Job copyWith({String? creditId, String? job, int? episodeCount}) => Job(
    creditId: creditId ?? this.creditId,
    job: job ?? this.job,
    episodeCount: episodeCount ?? this.episodeCount,
  );

  factory Job.fromJson(String str) => Job.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Job.fromMap(Map<String, dynamic> json) => Job(
    creditId: json["credit_id"],
    job: json["job"],
    episodeCount: json["episode_count"],
  );

  Map<String, dynamic> toMap() => {
    "credit_id": creditId,
    "job": job,
    "episode_count": episodeCount,
  };
}

class Role {
  String? creditId;
  String? character;
  int? episodeCount;

  Role({this.creditId, this.character, this.episodeCount});

  Role copyWith({String? creditId, String? character, int? episodeCount}) =>
      Role(
        creditId: creditId ?? this.creditId,
        character: character ?? this.character,
        episodeCount: episodeCount ?? this.episodeCount,
      );

  factory Role.fromJson(String str) => Role.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Role.fromMap(Map<String, dynamic> json) => Role(
    creditId: json["credit_id"],
    character: json["character"],
    episodeCount: json["episode_count"],
  );

  Map<String, dynamic> toMap() => {
    "credit_id": creditId,
    "character": character,
    "episode_count": episodeCount,
  };
}
