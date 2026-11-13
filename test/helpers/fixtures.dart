import 'package:cinerating/domain/entities/credits.dart';
import 'package:cinerating/domain/entities/genre.dart';
import 'package:cinerating/domain/entities/movie.dart';
import 'package:cinerating/domain/entities/tv_show.dart';
import 'package:cinerating/domain/entities/user.dart';

/// Dados de exemplo usados nos testes unitários, de widget e de integração.
///
/// As imagens (`posterPath`, `backdropPath`, `profilePath`) ficam nulas por
/// padrão: `MovieCard` usa `CachedNetworkImage`, que depende de plugins
/// (sqflite/path_provider) indisponíveis em `flutter test`.
class Fixtures {
  static final user = User(
    id: 42,
    username: 'cinefilo',
    name: 'Ana Cinéfila',
    sessionId: 'session-123',
  );

  static final movieA = Movie(
    id: 1,
    title: 'Interestelar',
    overview: 'Uma equipe viaja através de um buraco de minhoca.',
    voteAverage: 8.6,
    voteCount: 32000,
    runtime: 169,
    releaseDate: DateTime(2014, 11, 6),
    genres: const [Genre(id: 878, name: 'Ficção científica'), Genre(id: 18, name: 'Drama')],
  );

  static final movieB = Movie(
    id: 2,
    title: 'Cidade de Deus',
    overview: 'A vida no Rio de Janeiro dos anos 70.',
    voteAverage: 8.4,
    voteCount: 7000,
    runtime: 130,
    releaseDate: DateTime(2002, 8, 30),
    genres: const [Genre(id: 80, name: 'Crime')],
  );

  static final movies = [movieA, movieB];

  static final tvA = TvShow(
    id: 10,
    name: 'Breaking Bad',
    overview: 'Um professor de química vira fabricante de drogas.',
    voteAverage: 8.9,
    voteCount: 15000,
    firstAirDate: DateTime(2008, 1, 20),
    genres: const [Genre(id: 18, name: 'Drama')],
  );

  static final tvB = TvShow(
    id: 11,
    name: 'Dark',
    overview: 'Viagens no tempo em Winden.',
    voteAverage: 8.4,
    voteCount: 6000,
    firstAirDate: DateTime(2017, 12, 1),
  );

  static final tvShows = [tvA, tvB];

  static const actor = CastMember(
    id: 100,
    name: 'Matthew McConaughey',
    character: 'Cooper',
    department: 'Acting',
  );

  static const crewMember = CastMember(
    id: 101,
    name: 'Hans Zimmer',
    department: 'Sound',
    job: 'Original Music Composer',
  );

  static const director = CastMember(
    id: 102,
    name: 'Christopher Nolan',
    department: 'Directing',
    job: 'Director',
  );

  static const credits = Credits(cast: [actor, crewMember], director: director);
}
