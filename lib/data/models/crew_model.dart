import 'dart:convert';

import 'package:cinerating/core/shared/env.dart';

import '../../domain/entities/credits.dart';

class CrewModel {
  bool? adult;
  int? gender;
  int? id;
  String? knownForDepartment;
  String? name;
  String? job;
  String? originalName;
  double? popularity;
  String? profilePath;
  int? castId;
  String? character;
  String? creditId;
  int? order;

  CrewModel({
    this.adult,
    this.gender,
    this.id,
    this.knownForDepartment,
    this.name,
    this.job,
    this.originalName,
    this.popularity,
    this.profilePath,
    this.castId,
    this.character,
    this.creditId,
    this.order,
  });

  CrewModel copyWith({
    bool? adult,
    int? gender,
    int? id,
    String? knownForDepartment,
    String? name,
    String? job,
    String? originalName,
    double? popularity,
    String? profilePath,
    int? castId,
    String? character,
    String? creditId,
    int? order,
  }) => CrewModel(
    adult: adult ?? this.adult,
    gender: gender ?? this.gender,
    id: id ?? this.id,
    knownForDepartment: knownForDepartment ?? this.knownForDepartment,
    name: name ?? this.name,
    job: job ?? this.job,
    originalName: originalName ?? this.originalName,
    popularity: popularity ?? this.popularity,
    profilePath: profilePath ?? this.profilePath,
    castId: castId ?? this.castId,
    character: character ?? this.character,
    creditId: creditId ?? this.creditId,
    order: order ?? this.order,
  );

  factory CrewModel.fromJson(String str) => CrewModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CrewModel.fromMap(Map<String, dynamic> json) => CrewModel(
    adult: json["adult"],
    gender: json["gender"],
    id: json["id"],
    knownForDepartment: json["known_for_department"],
    name: json["name"],
    job: json["job"],
    originalName: json["original_name"],
    popularity: json["popularity"]?.toDouble(),
    profilePath: json["profile_path"] != null
        ? Environment.production.mediaUrl + json["profile_path"]
        : null,
    castId: json["cast_id"],
    character: json["character"],
    creditId: json["credit_id"],
    order: json["order"],
  );

  CastMember toEntity() => CastMember(
    id: id,
    name: name,
    character: character,
    profilePath: profilePath,
    department: knownForDepartment,
    job: job,
  );

  Map<String, dynamic> toMap() => {
    "adult": adult,
    "gender": gender,
    "id": id,
    "known_for_department": knownForDepartment,
    "name": name,
    "job": job,
    "original_name": originalName,
    "popularity": popularity,
    "profile_path": profilePath,
    "cast_id": castId,
    "character": character,
    "credit_id": creditId,
    "order": order,
  };
}
