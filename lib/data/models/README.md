# `lib/data/models/` — Models (DTOs)

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 4, 7.2 (V3).

## Objetivo
Converter JSON do TMDB em objetos Dart e, quando aplicável, em entidades de domínio.

## Responsabilidade principal
(De)serialização e montagem de URLs completas de imagem.

## Funcionalidades existentes
| Arquivo | Classes | Estende | Endpoint de origem |
|---|---|---|---|
| `movie_simple_model.dart` | `MovieSimpleModel` | `Movie` | itens de `/discover/*`, `/search/*` (filmes **e** séries) |
| `movie_detail_model.dart` | `MovieDetailModel`, `BelongsToCollection`, `Genre`, `ProductionCompany`, `ProductionCountry` | `Movie` | `/movie/{id}`, `/account/{id}/favorite/movies` |
| `tv_show_model.dart` | `TvShowModel`, `CreatedBy`, `Genre`, `LastEpisodeToAir`, `Network`, `ProductionCountry`, `Season`, `SpokenLanguage` | `TvShow` | `/tv/{id}` |
| `crew_model.dart` | `CrewModel` | — | itens de `cast`/`crew` de `/movie/{id}/credits` |
| `tv_crew_model.dart` | `TvShowCrew`, `Cast`, `Job`, `Role` | — | `/tv/{id}/aggregate_credits` |
| `user_model.dart` | `UserModel`, `AvatarModel` | `User`, `Avatar` | `/account` |

Padrão de cada model: `fromMap`, `toMap`, `fromJson(String)`, `toJson()`, `copyWith` (exceto `UserModel`/`AvatarModel`, que têm `fromJson(Map)`/`toJson()`).

## Dependências
- **Internas:** `domain/entities/*`, `core/shared/env.dart` (`mediaUrl`).
- **Externas:** `dart:convert`.

## Módulos relacionados
- Produzidos por: `data/datasources/implementations/*`, `core/services/*` (legado).
- **Consumidos indevidamente por:** `presentation/bloc/movie_detail/*`, `presentation/bloc/serie_detail/*`, `presentation/widgets/content_detail.dart`.

## Pontos de entrada
`XxxModel.fromMap(json)`.

## Fluxos importantes
- `poster_path`, `backdrop_path`, `profile_path` e `avatar` são convertidos para `https://media.themoviedb.org/t/p/w400<path>` no `fromMap`.
- `UserModel.fromJson` usa `name` ou, se ausente, `username`.

## Arquivos críticos
- `movie_detail_model.dart`, `movie_simple_model.dart`, `crew_model.dart`.

## Observações técnicas e débitos
- **[Débito]** `Genre` e `ProductionCountry` duplicados em `movie_detail_model.dart` e `tv_show_model.dart` (colisão de nomes se importados juntos).
- **[Débito]** `toMap()` usa `releaseDate!`, `firstAirDate!`, `lastAirDate!`, `airDate!` — lança exceção se a data for nula. **Hipótese:** sem impacto hoje porque `toMap()` não é chamado em nenhum fluxo.
- **[Risco]** `MovieDetailModel.fromMap` faz `DateTime.parse` sem tratar string vazia (o `MovieSimpleModel` trata). O mesmo vale para `TvShowModel`.
- **[Débito]** `toMap()` reemite URLs completas nos campos `*_path` (não é o inverso de `fromMap`).
- **[Débito]** `AvatarModel` concatena `mediaUrl` ao **hash** do Gravatar, gerando URL inválida para o Gravatar. **Hipótese:** sem impacto visível porque a UI usa apenas `avatar.tmdb`.
- **[Débito]** Campos mutáveis e anuláveis em todos os models; sem validação de schema.
