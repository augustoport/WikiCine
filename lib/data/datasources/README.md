# `lib/data/datasources/` — Fontes de dados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6.2–6.7, 7.2 (V1), 7.4.

## Objetivo
Encapsular as chamadas HTTP ao TMDB e a leitura/escrita do armazenamento seguro.

## Responsabilidade principal
Ser a única parte do app (fora do legado `core/services`) que fala com a rede.

## Estrutura
- `data/` — **interfaces** abstratas: `AuthData`, `MovieData`, `TvData`.
- `implementations/` — implementações concretas com `Dio`: `AuthImplementation`, `MovieImplementation`, `TvImplementation`.

## Funcionalidades existentes
Todas as requisições usam `baseUrl = Environment.production.baseUrl` e header `Authorization: Bearer <TOKEN>`.

### `AuthImplementation implements AuthData`
| Método | Requisição | Efeito colateral |
|---|---|---|
| `login` | orquestra os 3 abaixo + `getAccountDetails` | grava `tmdb_session_id` |
| `createRequestToken` (público, fora da interface) | `GET /authentication/token/new?api_key` | — |
| `validateLogin` (idem) | `POST /authentication/token/validate_with_login?api_key` | — |
| `createSession` (idem) | `POST /authentication/session/new?api_key` | — |
| `getAccountDetails(sessionId)` | `GET /account?session_id` + favoritos via `MovieApi(MovieImplementation())` | grava `account_id` |

### `MovieImplementation implements MovieData`
| Método | Requisição | Retorno |
|---|---|---|
| `getMovies` | `GET /discover/movie` | `List<Movie>` (`MovieSimpleModel`) |
| `searchMovies(q)` | `GET /search/movie?query&language=en-US;pt-BR` | `List<Movie>` |
| `getMovieDetails(id)` | `GET /movie/{id}` | `Movie` (`MovieDetailModel`) — **não usado** |
| `getMovieCrew(id)` | `GET /movie/{id}/credits` | JSON cru |
| `getMovieDetailsFull(id)` | `GET /movie/{id}` | JSON cru |
| `getFavoriteMovies` | lê `account_id`; `GET /account/{id}/favorite/movies` | `List<Movie>` (`MovieDetailModel`) |

### `TvImplementation implements TvData`
| Método | Requisição | Retorno |
|---|---|---|
| `getTvShows` | `GET /discover/tv` | `List<TvShow>` (via `MovieSimpleModel` → `_mapToEntity`) |
| `searchTvShows(q)` | `GET /search/tv?query&language=en-US;pt-BR` | `List<TvShow>` |
| `getTvShowDetails(id)` | `GET /tv/{id}` | `TvShow` — **não usado** |
| `getTvShowCrew(id)` | `GET /tv/{id}/aggregate_credits` | JSON cru |
| `getTvShowDetailsFull(id)` | `GET /tv/{id}` | JSON cru |

## Dependências
- **Internas:** `domain/entities/*`, `data/models/*`, `core/shared/env.dart`; `auth_implementation.dart` → `data/repositories/movie_api.dart` e `movie_implementation.dart`.
- **Externas:** `dio`, `flutter_secure_storage`.

## Módulos relacionados
- `data/repositories/*` (consumidores), `core/locator.dart` (registro como lazy singleton).

## Pontos de entrada
`getIt<AuthData>()`, `getIt<MovieData>()`, `getIt<TvData>()`.

## Fluxos importantes
- Login: ver seção 6.2 da arquitetura.
- `getAccountDetails` é chamado em **login**, **`checkExistingSession`** e **toda abertura de detalhe de filme** (via `GetCurrentUserUseCase` no `MovieCubit`) — sempre com a busca de favoritos junto.

## Arquivos críticos
- `implementations/auth_implementation.dart`
- `implementations/movie_implementation.dart`

## Observações técnicas e débitos
- **[Violação V1]** Datasource de auth depende de repositório + datasource de filmes, criados fora do locator (não compartilha a instância registrada).
- **[Violação R4]** Métodos `getXxxCrew`/`getXxxDetailsFull` retornam JSON cru.
- **[Débito]** `TvImplementation` usa `MovieSimpleModel` para séries; `getTvShowDetails` descarta os campos de detalhe.
- **[Débito]** Chaves de storage como literais (`'tmdb_session_id'`, `'account_id'`).
- **[Débito]** Nenhum tratamento de erro além do `try { } catch { rethrow; }` inócuo em `validateLogin`.
- **[Débito]** Sem paginação (parâmetro `page`).
- **[Risco S10]** `language: 'en-US;pt-BR'`. **Hipótese:** valor não reconhecido pelo TMDB.
- **[Risco S11]** Favoritos sem `session_id`. **Hipótese:** depende do `TOKEN` pertencer ao mesmo usuário.
- Interfaces em `data/` não declaram `createRequestToken`, `validateLogin`, `createSession` (métodos públicos só da implementação).
