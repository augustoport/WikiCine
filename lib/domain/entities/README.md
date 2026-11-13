# `lib/domain/entities/` — Entidades de domínio

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 3 (R3, R4).

## Objetivo
Modelar os conceitos centrais do app sem dependência de infraestrutura.

## Responsabilidade principal
Servir de tipo comum entre camadas: retorno de repositórios e casos de uso, estados de cubits e parâmetros de widgets.

## Funcionalidades existentes
| Entidade | Arquivo | Campos (todos `final`) |
|---|---|---|
| `Movie` | `movie.dart` | `id`, `runtime`, `title`, `name`, `overview`, `posterPath`, `backdropPath`, `voteAverage`, `voteCount`, `releaseDate`, `genreIds`, `genres` |
| `TvShow` | `tv_show.dart` | `id` (required), `name`, `overview`, `posterPath`, `backdropPath`, `voteAverage`, `voteCount`, `firstAirDate`, `genreIds`, `genres` |
| `Genre` | `genre.dart` | `id`, `name` |
| `CastMember` | `credits.dart` | `id`, `name`, `character`, `profilePath`, `department`, `job` |
| `Credits` | `credits.dart` | `cast` (`List<CastMember>`, padrão `[]`), `director` (`CastMember?`) |
| `User` | `user.dart` | `id`, `username`, `name`, `avatar`, `sessionId` |
| `Avatar` | `user.dart` | `gravatar`, `tmdb` (URLs completas ou `''`) |

## Dependências
- **Internas:** `movie.dart` e `tv_show.dart` → `genre.dart`.
- **Externas:** nenhuma.

## Módulos relacionados
- Estendidas por `data/models/`: `MovieSimpleModel`, `MovieDetailModel` → `Movie`; `TvShowModel` → `TvShow`; `GenreModel` → `Genre`; `UserModel` → `User`; `AvatarModel` → `Avatar`.
- Criadas por mapeamento (`toEntity()`): `CastMember`/`Credits` a partir de `CrewModel`, `Cast`, `TvShowCrew`.
- Usadas em estados de `presentation/bloc/*`, em `LoginController` e nos widgets `ContentDetail`/`CastCard`.

## Pontos de entrada
Construtores das classes.

## Fluxos importantes
`posterPath`, `backdropPath`, `profilePath` e avatar chegam **já como URL completa** (os models concatenam `mediaUrl`).

## Arquivos críticos
- `movie.dart`, `credits.dart`.

## Observações técnicas e débitos
- **[Débito]** Sem igualdade por valor (`==`/`hashCode`) nem `Equatable`.
- **[Débito]** `Movie` mistura `title` (filme) e `name` (série), porque listas de séries já usaram o mesmo tipo.
