/// Pessoa que participa de um filme ou série (elenco ou equipe).
class CastMember {
  final int? id;
  final String? name;
  final String? character;
  final String? profilePath;
  final String? department;
  final String? job;

  const CastMember({
    this.id,
    this.name,
    this.character,
    this.profilePath,
    this.department,
    this.job,
  });
}

/// Créditos de um título: elenco e, quando houver, direção.
class Credits {
  final List<CastMember> cast;
  final CastMember? director;

  const Credits({this.cast = const [], this.director});
}
