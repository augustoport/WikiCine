# `lib/domain/` — Camada de Domínio

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 1, 3 (R1, R4), 10.

## Objetivo
Representar o negócio (filmes, séries, usuário) independentemente de framework, HTTP ou UI.

## Responsabilidade principal
Definir **entidades**, **contratos de repositório** e **casos de uso** consumidos pela apresentação e implementados pela camada de dados.

## Submódulos
| Pasta | Conteúdo | README |
|---|---|---|
| `entities/` | `Movie`, `TvShow`, `User`, `Avatar` | [entities](./entities/README.md) |
| `repositories/` | `AuthRepository`, `MovieRepository`, `TvRepository`, `UserRepository` | [repositories](./repositories/README.md) |
| `usecases/` | 13 casos de uso em `auth/`, `movies/`, `tv_show/`, `user/` | [usecases](./usecases/README.md) |

## Dependências
- **Internas:** apenas entre seus próprios submódulos (`usecases → repositories → entities`).
- **Externas:** nenhuma (Dart puro). ✅ Regra R1 cumprida.

## Módulos relacionados
- Implementado por: `data/repositories/*`; estendido por: `data/models/*`.
- Consumido por: `presentation/bloc/*`, `presentation/controllers/login_controller.dart`, `core/locator.dart`.

## Pontos de entrada
Classes `*UseCase` (via `getIt`).

## Fluxos importantes
`Presentation → UseCase.call() → Repository (abstrato) → [data] implementação`.

## Arquivos críticos
- `repositories/movie_repository.dart`, `repositories/auth_repository.dart` (contratos mais usados).

## Observações técnicas e débitos
- **[Violação R4]** Contratos com `Future<dynamic>` vazam JSON para a apresentação.
- **[Órfão]** `UserRepository` e `GetUserFavoritesUsecases`.
- **[Débito]** Casos de uso não contêm regra de negócio (só delegam); regras como "diretor = job Director" e "é favorito?" estão na apresentação (`MovieCubit`).
- **[Débito]** Não há entidades para créditos/elenco nem para detalhes completos.
