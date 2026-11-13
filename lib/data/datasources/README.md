# `lib/data/datasources/` — Fontes de dados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 3 (R5), 6.2–6.7, 7.4.

## Objetivo
Encapsular as chamadas HTTP ao TMDB e a leitura/escrita do armazenamento seguro.

## Responsabilidade principal
Ser a única parte do app que fala com a rede. Um datasource não depende de outro datasource nem de repositórios (regra R5).

## Estrutura
- `data/` — **interfaces** abstratas: `AuthData`, `MovieData`, `TvData`, `UserData`.
- `implementations/` — implementações com `Dio`: `AuthImplementation`, `MovieImplementation`, `TvImplementation`, `UserImplementation`.

## Funcionalidades existentes
Todas as requisições usam `baseUrl = Environment.production.baseUrl` e o header `Authorization: Bearer <TOKEN>`.

### `AuthImplementation(FlutterSecureStorage)` implements `AuthData`
| Método | Requisição | Efeito colateral |
|---|---|---|
| `login` | orquestra os 3 abaixo + `getAccountDetails` | grava `StorageKeys.sessionId` |
| `createRequestToken` (público, fora da interface) | `GET /authentication/token/new?api_key` | — |
| `validateLogin` (idem) | `POST /authentication/token/validate_with_login?api_key` | — |
| `createSession` (idem) | `POST /authentication/session/new?api_key` | — |
| `getAccountDetails(sessionId)` | `GET /account?session_id` → `User` | grava `StorageKeys.accountId` |

### `MovieImplementation` implements `MovieData`
| Método | Requisição | Retorno |
|---|---|---|
| `getMovies` | `GET /discover/movie` | `List<Movie>` (`MovieSimpleModel`) |
| `searchMovies(q)` | `GET /search/movie?query&language=en-US;pt-BR` | `List<Movie>` |
| `getMovieDetails(id)` | `GET /movie/{id}` | `Movie` (`MovieDetailModel`) |
| `getMovieCredits(id)` | `GET /movie/{id}/credits` | `Credits`: `cast` = todos de `cast`; `director` = 1º de `crew` com `job == "Director"` |

### `TvImplementation` implements `TvData`
| Método | Requisição | Retorno |
|---|---|---|
| `getTvShows` | `GET /discover/tv` | `List<TvShow>` (via `MovieSimpleModel` → `_mapToEntity`) |
| `searchTvShows(q)` | `GET /search/tv?query&language=en-US;pt-BR` | `List<TvShow>` |
| `getTvShowDetails(id)` | `GET /tv/{id}` | `TvShow` (`TvShowModel`) |
| `getTvShowCredits(id)` | `GET /tv/{id}/aggregate_credits` | `Credits` (`TvShowCrew.toEntity()`; sem diretor) |

### `UserImplementation(FlutterSecureStorage)` implements `UserData`
| Método | Requisição | Retorno |
|---|---|---|
| `getFavoriteMovies` | lê `StorageKeys.accountId`; `GET /account/{id}/favorite/movies` | `List<Movie>` (`MovieDetailModel`) |

## Dependências
- **Internas:** `domain/entities/*`, `data/models/*`, `core/shared/env.dart`, `core/shared/storage_keys.dart`.
- **Externas:** `dio`, `flutter_secure_storage`.

## Módulos relacionados
- `data/repositories/*` (consumidores), `core/locator.dart` (registro como lazy singleton e injeção do `FlutterSecureStorage`).

## Pontos de entrada
Injetados nos repositórios pelo locator.

## Fluxos importantes
- Login: seção 6.2 da arquitetura.
- `UserImplementation` depende do `account_id` gravado por `AuthImplementation.getAccountDetails` (login ou sessão existente).

## Arquivos críticos
- `implementations/auth_implementation.dart`
- `implementations/movie_implementation.dart`

## Observações técnicas e débitos
- **[Débito]** `TvImplementation` usa `MovieSimpleModel` para listas de séries.
- **[Débito]** Nenhum tratamento de erro além do `try { } catch { rethrow; }` inócuo em `validateLogin`.
- **[Débito]** Sem paginação (parâmetro `page`).
- **[Risco S10]** `language: 'en-US;pt-BR'`. **Hipótese:** valor não reconhecido pelo TMDB.
- **[Risco S11]** Favoritos sem `session_id`. **Hipótese:** depende de o `TOKEN` pertencer ao mesmo usuário.
- As interfaces em `data/` não declaram `createRequestToken`, `validateLogin` e `createSession` (métodos públicos só da implementação).
