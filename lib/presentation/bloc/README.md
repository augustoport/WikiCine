# `lib/presentation/bloc/` — Cubits e estados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6.4–6.7, 7.1, 7.2.

## Objetivo
Gerenciar o estado assíncrono das telas com `Cubit` (`bloc`).

## Responsabilidade principal
Chamar casos de uso, tratar erros e emitir estados consumidos por `BlocBuilder`.

## Funcionalidades existentes
| Pasta | Cubit | Estados | Dependências (via `getIt`) | Locator |
|---|---|---|---|---|
| `home/` | `HomeCubit` — `getMovies()`, `getMovie(q)`, `getTvShows()`, `getTvShow(q)` | `HomeInitial`, `HomeLoading`, `HomeMovie(movies)`, `HomeTv(tvShows)`, `HomePeople` (não usado), `HomeError(message)` | `GetMoviesUseCase`, `SearchMoviesUseCase`, `GetTvShowsUseCase`, `SearchTvShowsUseCase` | factory |
| `movie_detail/` | `MovieCubit` — `getMovieDetails(id)`, `filterCrew(crew, detail)` | `MovieInitial`, `MovieLoading`, `MovieSuccess(movieDetail, cast, director, isFavorite)`, `MovieError(message)` | `GetMovieDetailsUseCase`, `GetMovieCrewUseCase`, `GetCurrentUserUseCase` | factory |
| `serie_detail/` | `SerieCubit` — `getSerieDetail(id)` | `SerieInitial`, `SerieLoading`, `SerieSuccess(tvShow, cast)`, `SerieError` | `GetTvShowDetailsUseCase`, `GetTvShowCrewUseCase` | **não registrado** |
| `profile/` | `ProfileCubit` — `initProfile()` | `ProfileInitial`, `ProfileLoading`, `ProfileSuccess(favorites, watchlist)`, `ProfileError` | `MovieRepository` (direto) | factory |

`home`, `movie_detail` e `serie_detail` usam `part`/`part of`; `profile` usa import normal.

## Dependências
- **Internas:** `core/locator.dart`, `domain/usecases/*`, `domain/entities/*`, `domain/repositories/movie_repository.dart`, `data/models/{crew_model,movie_detail_model,tv_show_model,tv_crew_model}.dart`.
- **Externas:** `bloc`.

## Módulos relacionados
- `pages/*` (consumidores), `controllers/home_controller.dart` (aciona `HomeCubit`).

## Pontos de entrada
`getIt<HomeCubit>()`, `getIt<MovieCubit>()`, `getIt<ProfileCubit>()`, `SerieCubit()`.

## Fluxos importantes
- **MovieCubit:** detalhes (JSON) + créditos (JSON) → `MovieDetailModel.fromMap` + `CrewModel.fromMap(cast)` → `filterCrew` (elenco `Acting`, diretor `job == "Director"`) → `GetCurrentUserUseCase` para `isFavorite` → `MovieSuccess`.
- **HomeCubit:** busca vazia recai em `getMovies()`/`getTvShows()`.

## Arquivos críticos
- `movie_detail/movie_cubit.dart`, `home/home_cubit.dart`.

## Observações técnicas e débitos
- **[Bug B1]** `MovieCubit` constrói a lista só com `crew['cast']`; o diretor nunca é encontrado.
- **[Débito]** `filterCrew` não é aguardado em `getMovieDetails` (sem `await`), então exceções lançadas nele escapam do `try/catch`.
- **[Débito]** Em `HomeCubit.getMovie`/`getTvShow`, a chamada de fallback `getMovies()`/`getTvShows()` também não é aguardada.
- **[Violação R3]** Estados `MovieSuccess` (`CrewModel`) e `SerieSuccess` (`TvShowModel`, `Cast`) expõem models de `data/`.
- **[Violação V5]** `ProfileCubit` usa repositório direto; `watchlist` sempre `[]`.
- **[Violação R6]** `SerieCubit` fora do locator.
- **[Débito]** Estados sem `Equatable`/igualdade; `SerieSuccess` tem campos mutáveis.
- **[Órfão]** `HomePeople`.
- **[Débito]** Nomes mistos `serie_*` vs `tv_show_*`; `serie_state.dart` no singular.
