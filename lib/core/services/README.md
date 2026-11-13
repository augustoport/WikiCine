# `lib/core/services/` — Serviços HTTP legados ⚠️ ÓRFÃO

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seção 7.3.

## Objetivo
Implementação **anterior** à migração para Clean Architecture (fluxo `Views → Controllers → Services → API`, segundo o `ARCHITECTURE.md` antigo).

## Responsabilidade principal
Nenhuma no app atual. **Nenhum arquivo do projeto importa estas classes e elas não estão registradas no locator.** (Verificado por busca em `lib/`.)

## Funcionalidades existentes (não utilizadas)
| Classe | Métodos | Endpoints |
|---|---|---|
| `AuthService({accessToken})` | `createRequestToken`, `validateLogin`, `createSession`, `login`, `getAccountDetails`, `getSessionId`, `getCurrentUser`, `clearSession` | `/authentication/token/new`, `/authentication/token/validate_with_login`, `/authentication/session/new`, `/account` |
| `MovieService` | `getMovies`, `getMovieByName`, `getMovieDetails`, `getMovieCrew` | `/discover/movie`, `/search/movie`, `/movie/{id}`, `/movie/{id}/credits` |
| `TvService` | `getTvShows`, `getTvShowByName`, `getShowId`, `getShowCrew` | `/discover/tv`, `/search/tv`, `/tv/{id}`, `/tv/{id}/aggregate_credits` |

## Dependências
- **Internas:** `core/shared/env.dart`, `data/models/{user_model,crew_model,movie_detail_model,movie_simple_model,tv_crew_model,tv_show_model}.dart`, `domain/entities/user.dart`.
- **Externas:** `dio`, `flutter_secure_storage`.

## Módulos relacionados
- Equivalentes atuais: `data/datasources/implementations/*`.

## Pontos de entrada
Nenhum em uso.

## Fluxos importantes
Referência histórica útil: `MovieService.getMovieCrew` junta `cast` **e** os membros de `crew` com `job == "Director"` — lógica que a implementação atual perdeu (ver bug B1 na arquitetura).

## Arquivos críticos
Nenhum (código morto).

## Observações técnicas e débitos
- **[Órfão]** Recomenda-se remover a pasta inteira após portar a lógica de diretor para `data/`.
- **[Débito]** Cria um `Dio` novo a cada chamada.
- **[Débito]** Falhas retornam `null` silenciosamente.
- O `ARCHITECTURE.md` antigo afirma que estes serviços são usados pelos cubits de detalhe — **isso não é mais verdade**.
- **Regra:** não adicionar código novo aqui.
