# `lib/data/` — Camada de Dados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 1, 3 (R4, R5), 6, 7.

## Objetivo
Implementar o acesso aos dados exigido pelo domínio, usando a API TMDB e o armazenamento seguro do dispositivo.

## Responsabilidade principal
Traduzir HTTP/JSON em entidades de domínio e implementar os contratos de `domain/repositories`. Todo parsing de JSON acontece aqui.

## Submódulos
| Pasta | Conteúdo | README |
|---|---|---|
| `datasources/` | Interfaces (`data/`) e implementações Dio (`implementations/`) | [datasources](./datasources/README.md) |
| `models/` | DTOs que estendem ou são mapeados para entidades | [models](./models/README.md) |
| `repositories/` | `AuthApi`, `MovieApi`, `TvRepositoryImpl`, `UserApi` | [repositories](./repositories/README.md) |

## Dependências
- **Internas:** `domain/entities/*`, `domain/repositories/*`, `core/shared/{env,storage_keys}.dart`.
- **Externas:** `dio`, `flutter_secure_storage`.

## Módulos relacionados
- `core/locator.dart` (registro e injeção). Nenhum módulo de `presentation/` importa `data/` (regra R3).

## Pontos de entrada
Via contratos de domínio resolvidos pelo locator.

## Fluxos importantes
`Repository impl → Datasource → Dio → TMDB → Model.fromMap / toEntity() → Entidade`.

## Arquivos críticos
- `datasources/implementations/auth_implementation.dart` (autenticação e sessão)
- `datasources/implementations/movie_implementation.dart` (filmes e créditos)

## Observações técnicas e débitos
- **[Débito]** Repositórios não agregam valor (sem cache, sem mapeamento de erro).
- **[Débito]** Quatro instâncias de `Dio` independentes, sem interceptors, timeout ou log.
