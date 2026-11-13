# `lib/domain/usecases/` — Casos de uso

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 3 (R2), 6, 10.

## Objetivo
Expor operações de negócio como classes com um único método `call()`.

## Responsabilidade principal
Ser a **única porta** da apresentação para o domínio (regra R2).

## Funcionalidades existentes
Todos são registrados como `factory` no locator.

| Pasta | Classe | Delegação / regra | Consumidor |
|---|---|---|---|
| `auth/` | `LoginUseCase` | `AuthRepository.login` | `LoginController` |
| `auth/` | `LogoutUseCase` | `AuthRepository.logout` | `LoginController` |
| `user/` | `GetCurrentUserUseCase` | `AuthRepository.getCurrentUser` | `LoginController` |
| `user/` | `GetUserFavoritesUseCase` | `UserRepository.getUserMovieFavorites` | `MovieCubit`, `ProfileCubit` |
| `movies/` | `GetMoviesUseCase` | `MovieRepository.getMovies` | `HomeCubit` |
| `movies/` | `SearchMoviesUseCase` | `MovieRepository.searchMovies` | `HomeCubit` |
| `movies/` | `GetMovieDetailsUseCase` | `MovieRepository.getMovieDetails` → `Movie` | `MovieCubit` |
| `movies/` | `GetMovieCrewUseCase` | `MovieRepository.getMovieCredits` → `Credits`, **mantendo no elenco só `department == "Acting"`** | `MovieCubit` |
| `tv_show/` | `GetTvShowsUseCase` | `TvRepository.getTvShows` | `HomeCubit` |
| `tv_show/` | `SearchTvShowsUseCase` | `TvRepository.searchTvShows` | `HomeCubit` |
| `tv_show/` | `GetTvShowDetailsUseCase` | `TvRepository.getTvShowDetails` → `TvShow` | `SerieCubit` |
| `tv_show/` | `GetTvShowCrewUseCase` | `TvRepository.getTvShowCredits` → `Credits` | `SerieCubit` |

## Dependências
- **Internas:** `domain/repositories/*`, `domain/entities/*`.
- **Externas:** nenhuma.

## Módulos relacionados
- `core/locator.dart` (registro e injeção), `presentation/bloc/*`, `presentation/controllers/login_controller.dart`.

## Pontos de entrada
Construtor (recebe o repositório) e `call(...)`.

## Fluxos importantes
Ver fluxos 6.2 a 6.7 na arquitetura.

## Arquivos críticos
- `auth/login_usecase.dart`, `movies/get_movie_crew_usecase.dart`.

## Observações técnicas e débitos
- **[Débito]** `GetCurrentUserUseCase` está em `user/`, mas depende de `AuthRepository`.
- **[Débito]** Nomes `GetMovieCrewUseCase`/`GetTvShowCrewUseCase` retornam `Credits` (elenco + diretor); poderiam ser renomeados para `Get...CreditsUseCase`.
- **Candidato a caso de uso:** "este filme é favorito?" (hoje calculado no `MovieCubit`).
