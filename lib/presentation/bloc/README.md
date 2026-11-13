# `lib/presentation/bloc/` — Cubits e estados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6.4–6.7, 7.1, 7.2.

## Objetivo
Gerenciar o estado assíncrono das telas com `Cubit` (`bloc`).

## Responsabilidade principal
Chamar casos de uso, tratar erros e emitir estados consumidos por `BlocBuilder`.

## Funcionalidades existentes
Todos os cubits recebem os casos de uso **pelo construtor** e são registrados como `factory` no locator.

| Pasta | Cubit | Estados | Casos de uso injetados |
|---|---|---|---|
| `home/` | `HomeCubit` — `getMovies()`, `getMovie(q)`, `getTvShows()`, `getTvShow(q)` | `HomeInitial`, `HomeLoading`, `HomeMovie(movies)`, `HomeTv(tvShows)`, `HomeError(message)` | `GetMoviesUseCase`, `SearchMoviesUseCase`, `GetTvShowsUseCase`, `SearchTvShowsUseCase` |
| `movie_detail/` | `MovieCubit` — `getMovieDetails(id)` | `MovieInitial`, `MovieLoading`, `MovieSuccess(Movie, List<CastMember> cast, CastMember? director, bool isFavorite)`, `MovieError(message)` | `GetMovieDetailsUseCase`, `GetMovieCrewUseCase`, `GetUserFavoritesUseCase` |
| `serie_detail/` | `SerieCubit` — `getSerieDetail(id)` | `SerieInitial`, `SerieLoading`, `SerieSuccess(TvShow, List<CastMember>)`, `SerieError` | `GetTvShowDetailsUseCase`, `GetTvShowCrewUseCase` |
| `profile/` | `ProfileCubit` — `initProfile()` | `ProfileInitial`, `ProfileLoading`, `ProfileSuccess(favorites, watchlist)`, `ProfileError` | `GetUserFavoritesUseCase` |

`home`, `movie_detail` e `serie_detail` usam `part`/`part of`; `profile` usa import normal.

## Dependências
- **Internas:** `domain/usecases/*`, `domain/entities/*`.
- **Externas:** `bloc`.

## Módulos relacionados
- `pages/*` (consumidores), `controllers/home_controller.dart` (aciona `HomeCubit`), `core/locator.dart` (criação).

## Pontos de entrada
`getIt<HomeCubit>()`, `getIt<MovieCubit>()`, `getIt<SerieCubit>()`, `getIt<ProfileCubit>()` (nas pages). Em testes, instanciar direto com casos de uso falsos.

## Fluxos importantes
- **MovieCubit:** detalhes (`Movie`) + créditos (`Credits`, só atores) → `isFavorite` = filme está em `GetUserFavoritesUseCase()` (`false` se a busca falhar) → `MovieSuccess`.
- **HomeCubit:** busca vazia recai em `getMovies()`/`getTvShows()`.

## Arquivos críticos
- `movie_detail/movie_cubit.dart`, `home/home_cubit.dart`.

## Observações técnicas e débitos
- **[Débito]** Em `HomeCubit.getMovie`/`getTvShow`, a chamada de fallback `getMovies()`/`getTvShows()` não é aguardada.
- **[Débito]** `ProfileSuccess.watchlist` é sempre `[]`.
- **[Débito]** Estados sem `Equatable`/igualdade.
- **[Débito]** Nomes mistos `serie_*` vs `tv_show_*`; `serie_state.dart` no singular.
