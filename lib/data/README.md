# `lib/data/` — Camada de Dados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 1, 6, 7.

## Objetivo
Implementar o acesso aos dados exigido pelo domínio, usando a API TMDB e o armazenamento seguro do dispositivo.

## Responsabilidade principal
Traduzir HTTP/JSON em entidades de domínio e implementar os contratos de `domain/repositories`.

## Submódulos
| Pasta | Conteúdo | README |
|---|---|---|
| `datasources/` | Interfaces (`data/`) e implementações Dio (`implementations/`) | [datasources](./datasources/README.md) |
| `models/` | DTOs que estendem entidades | [models](./models/README.md) |
| `repositories/` | `AuthApi`, `MovieApi`, `TvRepositoryImpl` | [repositories](./repositories/README.md) |

## Dependências
- **Internas:** `domain/entities/*`, `domain/repositories/*`, `core/shared/env.dart`.
- **Externas:** `dio`, `flutter_secure_storage`.

## Módulos relacionados
- `core/locator.dart` (registro), `presentation/bloc/*` e `presentation/widgets/content_detail.dart` (importam `models/` — violação R3), `core/services/*` (legado que importa `models/`).

## Pontos de entrada
Via contratos de domínio resolvidos pelo locator.

## Fluxos importantes
`Repository impl → Datasource → Dio → TMDB → Model.fromMap → Entidade`.

## Arquivos críticos
- `datasources/implementations/auth_implementation.dart` (autenticação e sessão)
- `datasources/implementations/movie_implementation.dart` (filmes e favoritos)

## Observações técnicas e débitos
- **[Violação V1]** `AuthImplementation` instancia `MovieApi(MovieImplementation())`.
- **[Débito]** Repositórios não agregam valor (sem cache, sem mapeamento de erro).
- **[Débito]** Três instâncias de `Dio` independentes, sem interceptors, timeout ou log.
