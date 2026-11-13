# `lib/domain/` — Camada de Domínio

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 1, 3 (R1, R4), 10.

## Objetivo
Representar o negócio (filmes, séries, créditos, usuário) independentemente de framework, HTTP ou UI.

## Responsabilidade principal
Definir **entidades**, **contratos de repositório** e **casos de uso** consumidos pela apresentação e implementados pela camada de dados.

## Submódulos
| Pasta | Conteúdo | README |
|---|---|---|
| `entities/` | `Movie`, `TvShow`, `Genre`, `Credits`, `CastMember`, `User`, `Avatar` | [entities](./entities/README.md) |
| `repositories/` | `AuthRepository`, `MovieRepository`, `TvRepository`, `UserRepository` | [repositories](./repositories/README.md) |
| `usecases/` | 12 casos de uso em `auth/`, `movies/`, `tv_show/`, `user/` | [usecases](./usecases/README.md) |

## Dependências
- **Internas:** apenas entre seus próprios submódulos (`usecases → repositories → entities`).
- **Externas:** nenhuma (Dart puro). ✅ Regra R1.

## Módulos relacionados
- Implementado por: `data/repositories/*`; estendido por: `data/models/*`.
- Consumido por: `presentation/bloc/*`, `presentation/controllers/login_controller.dart`, `presentation/widgets/*` (entidades), `core/locator.dart`.

## Pontos de entrada
Classes `*UseCase`, injetadas pelo locator nos cubits/controllers.

## Fluxos importantes
`Presentation → UseCase.call() → Repository (abstrato) → [data] implementação`.

## Arquivos críticos
- `repositories/movie_repository.dart`, `repositories/auth_repository.dart`, `entities/credits.dart`.

## Observações técnicas e débitos
- ✅ Todos os contratos são tipados (regra R4); não há `dynamic` no domínio.
- **[Débito]** A maioria dos casos de uso só delega. Exceção: `GetMovieCrewUseCase` filtra o elenco por departamento "Acting". O cálculo de "é favorito?" ainda está no `MovieCubit`.
