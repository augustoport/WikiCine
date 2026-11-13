# `lib/domain/repositories/` — Contratos de repositório

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 3 (R4), 7.2 (V2), 7.3.

## Objetivo
Definir as interfaces de acesso a dados que o domínio precisa, sem saber como são implementadas.

## Responsabilidade principal
Inversão de dependência: `domain` declara, `data` implementa.

## Funcionalidades existentes
| Contrato | Métodos | Implementação |
|---|---|---|
| `AuthRepository` | `login({username, password}) → User`; `getCurrentUser() → User?`; `logout()` | `data/repositories/auth_api.dart` (`AuthApi`) |
| `MovieRepository` | `getMovies()`, `searchMovies(query)` → `List<Movie>`; `getMovieDetails(id) → Movie`; `getMovieCrew(id) → dynamic`; `getMovieDetailsFull(id) → dynamic`; `getFavoriteMovies() → List<Movie>` | `data/repositories/movie_api.dart` (`MovieApi`) |
| `TvRepository` | `getTvShows()`, `searchTvShows(query)` → `List<TvShow>`; `getTvShowDetails(id) → TvShow`; `getTvShowCrew(id) → dynamic`; `getTvShowDetailsFull(id) → dynamic` | `data/repositories/tv_api.dart` (`TvRepositoryImpl`) |
| `UserRepository` | `getUserMovieFavorites() → List<Movie>` | **Nenhuma** |

## Dependências
- **Internas:** `domain/entities/*`.
- **Externas:** nenhuma.

## Módulos relacionados
- Usados por: `domain/usecases/*`, `presentation/bloc/profile/profile_cubit.dart` (direto — violação), `core/locator.dart`.

## Pontos de entrada
`getIt<AuthRepository>()`, `getIt<MovieRepository>()`, `getIt<TvRepository>()`.

## Fluxos importantes
Ver fluxos 6.2–6.7 na arquitetura.

## Arquivos críticos
- `movie_repository.dart`, `auth_repository.dart`.

## Observações técnicas e débitos
- **[Violação V2/R4]** Quatro métodos retornam `dynamic` (JSON). Os equivalentes tipados (`getMovieDetails`, `getTvShowDetails`) existem, mas **nenhum caso de uso os usa**.
- **[Órfão]** `UserRepository` — sem implementação nem uso. Sua responsabilidade (favoritos) está hoje em `MovieRepository.getFavoriteMovies`.
- **[Débito]** Favoritos de usuário estão no repositório de filmes, misturando catálogo público e dados de conta.
