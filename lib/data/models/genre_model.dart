import '../../domain/entities/genre.dart';

class GenreModel extends Genre {
  const GenreModel({super.id, super.name});

  factory GenreModel.fromMap(Map<String, dynamic> json) =>
      GenreModel(id: json["id"], name: json["name"]);

  static Map<String, dynamic> toMap(Genre genre) => {
    "id": genre.id,
    "name": genre.name,
  };
}
