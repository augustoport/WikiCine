# `lib/domain/usecases/` — Casos de uso

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 6, 10.

## Objetivo
Expor operações de negócio como classes com um único método `call()`.

## Responsabilidade principal
Ser a **única porta** da apresentação para o domínio (regra R2).

## Funcionalidades existentes
| Pasta | Classe | Delegação | Registrado no locator | Consumidor |
|---|---|---|---|---|
| `auth/` | `LoginUseCase` | `AuthRepository.login` | ✅ factory | `LoginController` |
| `auth/` | `LogoutUseCase` | `AuthRepository.logout` | ✅ factory | `LoginController` |
| `user/` | `GetCurrentUserUseCase` | `AuthRepository.getCurrentUser` | ✅ factory | `LoginController`, `MovieCubit` |
| `user/` | `GetUserFavoritesUsecases` | `MovieRepository.getFavoriteMovies` | ❌ | **Nenhum (órfão)** |
| `movies/` | `GetMoviesUseCase` | `MovieRepository.getMovies` | ✅ factory | `HomeCubit` |
| `movies/` | `SearchMoviesUseCase` | `MovieRepository.searchMovies` | ✅ factory | `HomeCubit` |
| `movies/` | `GetMovieDetailsUseCase` | `MovieRepository.getMovieDetailsFull` → `dynamic` | ✅ factory | `MovieCubit` |
| `movies/` | `GetMovieCrewUseCase` | `MovieRepository.getMovieCrew` → `dynamic` | ✅ factory | `MovieCubit` |
| `tv_show/` | `GetTvShowsUseCase` | `TvRepository.getTvShows` | ✅ factory | `HomeCubit` |
| `tv_show/` | `SearchTvShowsUseCase` | `TvRepository.searchTvShows` | ✅ factory | `HomeCubit` |
| `tv_show/` | `GetTvShowDetailsUseCase` | `TvRepository.getTvShowDetailsFull` → `dynamic` | ✅ factory | `SerieCubit` |
| `tv_show/` | `GetTvShowCrewUseCase` | `TvRepository.getTvShowCrew` → `dynamic` | ✅ factory | `SerieCubit` |

## Dependências
- **Internas:** `domain/repositories/*`, `domain/entities/*`.
- **Externas:** nenhuma.

## Módulos relacionados
- `core/locator.dart` (registro), `presentation/bloc/*`, `presentation/controllers/login_controller.dart`.

## Pontos de entrada
`getIt<XxxUseCase>()` e então `useCase(...)`.

## Fluxos importantes
Ver fluxos 6.2 a 6.6 na arquitetura.

## Arquivos críticos
- `auth/login_usecase.dart`, `movies/get_movie_details_usecase.dart`, `movies/get_movie_crew_usecase.dart`.

## Observações técnicas e débitos
- **[Débito]** Todos são *pass-through*; nenhuma regra de negócio. Candidatas a mover para cá: seleção de elenco/diretor e cálculo de "é favorito" (hoje em `MovieCubit`).
- **[Violação R4]** `GetMovieDetailsUseCase` usa o método `...Full` (`dynamic`) em vez do tipado `getMovieDetails`. Idem para TV.
- **[Débito]** `GetCurrentUserUseCase` está em `user/` mas depende de `AuthRepository`.
- **[Órfão]** `GetUserFavoritesUsecases` (nome também fora do padrão: deveria ser `GetUserFavoritesUseCase`). `ProfileCubit` deveria usá-lo.
