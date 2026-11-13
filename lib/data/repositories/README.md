# `lib/data/repositories/` — Implementações de repositório

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 4.2, 6.

## Objetivo
Implementar os contratos de `domain/repositories` usando os datasources.

## Responsabilidade principal
Ponte entre domínio e fontes de dados; ponto natural para cache, mapeamento de erros e combinação de fontes (hoje não utilizado para isso).

## Funcionalidades existentes
| Arquivo | Classe | Implementa | Dependências (construtor) | Comportamento |
|---|---|---|---|---|
| `auth_api.dart` | `AuthApi` | `AuthRepository` | `AuthData`, `FlutterSecureStorage` | `login` delega; `getCurrentUser` lê `tmdb_session_id` e chama `getAccountDetails` (retorna `null` em erro); `logout` apaga `tmdb_session_id`. |
| `movie_api.dart` | `MovieApi` | `MovieRepository` | `MovieData` | Delegação 1:1. |
| `tv_api.dart` | `TvRepositoryImpl` | `TvRepository` | `TvData` (nomeado `remoteDataSource`) | Delegação 1:1. |

## Dependências
- **Internas:** `domain/repositories/*`, `domain/entities/*`, `data/datasources/data/*`.
- **Externas:** `flutter_secure_storage` (apenas `AuthApi`).

## Módulos relacionados
- `core/locator.dart` (lazy singleton), `domain/usecases/*`, `presentation/bloc/profile/profile_cubit.dart` (uso direto de `MovieRepository`), `data/datasources/implementations/auth_implementation.dart` (instancia `MovieApi` — violação V1).

## Pontos de entrada
`getIt<AuthRepository>()`, `getIt<MovieRepository>()`, `getIt<TvRepository>()`.

## Fluxos importantes
- Sessão persistida: `AuthApi.getCurrentUser` é a base do "lembrar login".

## Arquivos críticos
- `auth_api.dart`

## Observações técnicas e débitos
- **[Débito]** Nomenclatura inconsistente (`*Api` vs `*RepositoryImpl`; arquivo `tv_api.dart` contém `TvRepositoryImpl`).
- **[Bug B5]** `logout` não remove `account_id` nem invalida a sessão no TMDB.
- **[Débito]** Responsabilidade de storage dividida entre `AuthApi` (lê/apaga) e `AuthImplementation` (grava).
- **[Débito]** Erros em `getCurrentUser` são silenciados (`catch (e) { return null; }`).
