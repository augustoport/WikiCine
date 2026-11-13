# `lib/core/` — Núcleo transversal

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 6.9 e 7.

## Objetivo
Agrupar o que não pertence a uma camada específica: composição de dependências, configuração de ambiente, tema e código legado.

## Responsabilidade principal
`locator.dart` é o **composition root**: registra no `get_it` todas as implementações usadas pelo app.

## Funcionalidades existentes
- `final getIt = GetIt.instance` — instância global.
- `setupLocator()` registra:
  - `AppColors` (singleton);
  - datasources `AuthData`, `MovieData`, `TvData` (lazy singleton);
  - repositórios `AuthRepository → AuthApi(AuthData, FlutterSecureStorage())`, `MovieRepository → MovieApi`, `TvRepository → TvRepositoryImpl` (lazy singleton);
  - 12 casos de uso (factory), incluindo `GetUserFavoritesUsecases`;
  - `LoginController` (lazy singleton), `HomeController` (factory);
  - `HomeCubit`, `ProfileCubit`, `MovieCubit` (factory).

## Submódulos
| Pasta | README |
|---|---|
| `shared/` | [shared](./shared/README.md) — ambiente, tema, rotas |
| `services/` | [services](./services/README.md) — **legado órfão** |

## Dependências
- **Internas:** `data/datasources/**`, `data/repositories/**`, `domain/repositories/**`, `domain/usecases/**`, `presentation/bloc/{home,movie_detail,profile}`, `presentation/controllers/**`, `core/shared/themes/app_colors.dart`.
- **Externas:** `get_it`, `flutter_secure_storage`.

## Módulos relacionados
- Consumido por: `main.dart`, todos os cubits, controllers e pages (via `getIt<T>()`).

## Pontos de entrada
- `setupLocator()` (chamado em `main.dart`).

## Fluxos importantes
Resolução em cadeia, ex.: `getIt<HomeCubit>()` → construtor faz `getIt<GetMoviesUseCase>()` → `getIt<MovieRepository>()` → `getIt<MovieData>()`.

## Arquivos críticos
- `locator.dart`

## Observações técnicas e débitos
- **[Violação V6]** `core/` importa `presentation/`; ao mesmo tempo `data/` e `presentation/` importam `core/`. O locator poderia ser movido para fora de `core/` (ex.: `lib/di/`) para quebrar o ciclo conceitual.
- **[Violação R6]** Não registra `SerieCubit` nem implementação de `UserRepository`.
- **[Débito]** `AppColors` registrado como instância, mas só possui campos `static`.
- **[Bug B2]** Por `HomeCubit` ser `registerFactory`, o `getIt<HomeCubit>()` do Drawer cria uma instância desconectada da Home.
- **[Débito]** `LoginController` é lazy singleton e guarda `TextEditingController`s que nunca são descartados.
- Registro tardio: erros de dependência faltante só aparecem em tempo de execução.
