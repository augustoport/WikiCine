# `lib/core/` — Núcleo transversal

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 3 (R6), 6.9 e 7.

## Objetivo
Agrupar o que não pertence a uma camada específica: composição de dependências, configuração de ambiente, chaves de storage e tema.

## Responsabilidade principal
`locator.dart` é o **composition root**: registra no `get_it` todas as implementações e injeta as dependências pelo construtor.

## Funcionalidades existentes
- `final getIt = GetIt.instance` — instância global.
- `setupLocator()` registra:
  - `FlutterSecureStorage` (lazy singleton, instância única);
  - datasources `AuthData`, `MovieData`, `TvData`, `UserData` (lazy singleton);
  - repositórios `AuthRepository → AuthApi`, `MovieRepository → MovieApi`, `TvRepository → TvRepositoryImpl`, `UserRepository → UserApi` (lazy singleton);
  - 12 casos de uso (factory);
  - `LoginController` (lazy singleton), `HomeController` (factory);
  - `HomeCubit`, `MovieCubit`, `SerieCubit`, `ProfileCubit` (factory), todos com casos de uso injetados.

## Submódulos
| Pasta | README |
|---|---|
| `shared/` | [shared](./shared/README.md) — ambiente, chaves de storage, tema |

## Dependências
- **Internas:** `data/datasources/**`, `data/repositories/**`, `domain/repositories/**`, `domain/usecases/**`, `presentation/bloc/**`, `presentation/controllers/**`.
- **Externas:** `get_it`, `flutter_secure_storage`.

## Módulos relacionados
- Consumido por: `main.dart` (`setupLocator`) e `presentation/pages/*` (`getIt<T>()` para cubits/controllers).

## Pontos de entrada
- `setupLocator()` (chamado em `main.dart`).

## Fluxos importantes
Ex.: `getIt<MovieCubit>()` → `MovieCubit(getMovieDetailsUseCase: getIt(), getMovieCrewUseCase: getIt(), getUserFavoritesUseCase: getIt())` → cada caso de uso recebe seu repositório → cada repositório recebe seu datasource.

## Arquivos críticos
- `locator.dart`

## Observações técnicas e débitos
- **[Violação V6]** `core/` importa `presentation/`; ao mesmo tempo `data/` e `presentation/` importam `core/shared`. O locator poderia ser movido para fora de `core/` (ex.: `lib/di/`).
- **[Bug B2]** Por `HomeCubit` ser `registerFactory`, o `getIt<HomeCubit>()` do Drawer cria uma instância desconectada da Home.
- **[Débito]** `LoginController` é lazy singleton e guarda `TextEditingController`s que nunca são descartados.
- Erros de dependência faltante só aparecem em tempo de execução.
- **Regra:** toda classe nova de datasource, repositório, caso de uso, cubit ou controller deve ser registrada aqui.
