# `lib/domain/entities/` — Entidades de domínio

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 7.2 (V9).

## Objetivo
Modelar os conceitos centrais do app sem dependência de infraestrutura.

## Responsabilidade principal
Servir de tipo comum entre camadas (retorno de repositórios e casos de uso, estados de cubits).

## Funcionalidades existentes
| Entidade | Campos | Observação |
|---|---|---|
| `Movie` (`movie.dart`) | `id`, `runtime`, `title`, `name`, `overview`, `posterPath`, `backdropPath`, `voteAverage`, `releaseDate`, `genreIds` — todos `final` e anuláveis | Possui `name` (campo de série) para reaproveitar o tipo em listas. |
| `TvShow` (`tv_show.dart`) | `id` (required), `name`, `overview`, `posterPath`, `backdropPath`, `voteAverage`, `firstAirDate`, `genreIds` | — |
| `User` (`user.dart`) | `id`, `username`, `name`, `avatar`, `sessionId` (`final`); `favoriteMovies` (`List<Movie?>?`, **mutável**) | — |
| `Avatar` (`user.dart`) | `gravatar`, `tmdb` (URLs completas ou `''`) | — |

## Dependências
- **Internas:** `user.dart` → `movie.dart`.
- **Externas:** nenhuma.

## Módulos relacionados
- Estendidas por `data/models/`: `MovieSimpleModel`, `MovieDetailModel` → `Movie`; `TvShowModel` → `TvShow`; `UserModel` → `User`; `AvatarModel` → `Avatar`.
- Usadas em estados de `presentation/bloc/*` e em `LoginController`.

## Pontos de entrada
Construtores das classes.

## Fluxos importantes
`posterPath`, `backdropPath` e avatar chegam **já como URL completa** (os models concatenam `mediaUrl`).

## Arquivos críticos
- `movie.dart`, `user.dart`.

## Observações técnicas e débitos
- **[Violação V9]** `User.favoriteMovies` é mutável e preenchido após a construção.
- **[Débito]** Sem igualdade por valor (`==`/`hashCode`) nem `Equatable`.
- **[Débito]** `Movie` mistura `title` (filme) e `name` (série).
- **[Débito]** Faltam entidades para detalhes (gêneros, duração de série) e créditos (elenco/diretor); hoje esses dados vivem só em models de `data/`.
