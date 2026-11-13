# `lib/data/models/` — Models (DTOs)

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 4.

## Objetivo
Converter JSON do TMDB em objetos Dart e em entidades de domínio.

## Responsabilidade principal
(De)serialização, montagem de URLs completas de imagem e mapeamento para entidades. São usados **somente dentro de `data/`** (regra R3).

## Funcionalidades existentes
| Arquivo | Classes | Relação com domínio | Endpoint de origem |
|---|---|---|---|
| `movie_simple_model.dart` | `MovieSimpleModel` | estende `Movie` | itens de `/discover/*`, `/search/*` (filmes **e** séries) |
| `movie_detail_model.dart` | `MovieDetailModel`, `BelongsToCollection`, `ProductionCompany`, `ProductionCountry` | `MovieDetailModel` estende `Movie` | `/movie/{id}`, `/account/{id}/favorite/movies` |
| `tv_show_model.dart` | `TvShowModel`, `CreatedBy`, `LastEpisodeToAir`, `Network`, `ProductionCountry`, `Season`, `SpokenLanguage` | `TvShowModel` estende `TvShow` | `/tv/{id}` |
| `genre_model.dart` | `GenreModel` | estende `Genre` | campo `genres` de detalhes |
| `crew_model.dart` | `CrewModel` | `toEntity() → CastMember` | itens de `cast`/`crew` de `/movie/{id}/credits` |
| `tv_crew_model.dart` | `TvShowCrew`, `Cast`, `Job`, `Role` | `TvShowCrew.toEntity() → Credits`; `Cast.toEntity() → CastMember` (personagem = `roles[0]`, função = `jobs[0]`) | `/tv/{id}/aggregate_credits` |
| `user_model.dart` | `UserModel`, `AvatarModel` | estendem `User`, `Avatar` | `/account` |

Padrão: `fromMap`, `toMap`, `fromJson(String)`, `toJson()`, `copyWith` (exceto `GenreModel`, `UserModel`, `AvatarModel`).

## Dependências
- **Internas:** `domain/entities/*`, `core/shared/env.dart` (`mediaUrl`).
- **Externas:** `dart:convert`.

## Módulos relacionados
- Produzidos e consumidos por `data/datasources/implementations/*`.

## Pontos de entrada
`XxxModel.fromMap(json)` e `toEntity()`.

## Fluxos importantes
- `poster_path`, `backdrop_path`, `profile_path` e `avatar` viram `https://media.themoviedb.org/t/p/w400<path>` no `fromMap`.
- `UserModel.fromJson` usa `name` ou, se ausente, `username`.

## Arquivos críticos
- `movie_detail_model.dart`, `crew_model.dart`, `tv_crew_model.dart`.

## Observações técnicas e débitos
- **[Débito]** `ProductionCountry` duplicado em `movie_detail_model.dart` e `tv_show_model.dart`.
- **[Débito]** `toMap()` usa `releaseDate!`, `firstAirDate!`, `lastAirDate!`, `airDate!` — lança exceção se a data for nula. **Hipótese:** sem impacto hoje porque `toMap()` não é chamado em nenhum fluxo.
- **[Risco]** `MovieDetailModel.fromMap` e `TvShowModel.fromMap` fazem `DateTime.parse` sem tratar string vazia (o `MovieSimpleModel` trata).
- **[Débito]** `AvatarModel` concatena `mediaUrl` ao **hash** do Gravatar, gerando URL inválida. **Hipótese:** sem impacto visível porque a UI usa apenas `avatar.tmdb`.
- **[Débito]** Campos mutáveis e anuláveis; sem validação de schema.
