# `lib/domain/repositories/` — Contratos de repositório

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 3 (R4), 6.

## Objetivo
Definir as interfaces de acesso a dados que o domínio precisa, sem saber como são implementadas.

## Responsabilidade principal
Inversão de dependência: `domain` declara, `data` implementa. Todos os retornos são entidades tipadas (regra R4).

## Funcionalidades existentes
| Contrato | Métodos | Implementação |
|---|---|---|
| `AuthRepository` | `login({username, password}) → User`; `getCurrentUser() → User?`; `logout()` | `data/repositories/auth_api.dart` (`AuthApi`) |
| `MovieRepository` | `getMovies()`, `searchMovies(query)` → `List<Movie>`; `getMovieDetails(id) → Movie`; `getMovieCredits(id) → Credits` | `data/repositories/movie_api.dart` (`MovieApi`) |
| `TvRepository` | `getTvShows()`, `searchTvShows(query)` → `List<TvShow>`; `getTvShowDetails(id) → TvShow`; `getTvShowCredits(id) → Credits` | `data/repositories/tv_api.dart` (`TvRepositoryImpl`) |
| `UserRepository` | `getUserMovieFavorites() → List<Movie>` | `data/repositories/user_api.dart` (`UserApi`) |

## Dependências
- **Internas:** `domain/entities/*`.
- **Externas:** nenhuma.

## Módulos relacionados
- Usados por: `domain/usecases/*`, `core/locator.dart`. A apresentação **não** os acessa diretamente (regra R2).

## Pontos de entrada
Injetados nos casos de uso pelo locator.

## Fluxos importantes
Ver fluxos 6.2–6.7 na arquitetura.

## Arquivos críticos
- `movie_repository.dart`, `auth_repository.dart`, `user_repository.dart`.

## Observações técnicas e débitos
- Favoritos do usuário ficam em `UserRepository` (dados de conta), separados do catálogo público (`MovieRepository`).
