# `lib/core/shared/` — Configuração compartilhada

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 3 (R7), 7.5.

## Objetivo
Centralizar constantes de ambiente, de armazenamento e de tema usadas por várias camadas.

## Responsabilidade principal
`env.dart` é a **única** fonte de URLs e credenciais (regra R7).

## Funcionalidades existentes
| Arquivo | Conteúdo |
|---|---|
| `env.dart` | `enum Environment { production }` com `baseUrl = https://api.themoviedb.org/3`, `mediaUrl = https://media.themoviedb.org/t/p/w400`, `signupUrl = https://www.themoviedb.org/signup`, `token = String.fromEnvironment('TOKEN')`, `apiKey = String.fromEnvironment('API_KEY')`. |
| `storage_keys.dart` | `StorageKeys.sessionId = 'tmdb_session_id'`, `StorageKeys.accountId = 'account_id'`. |
| `themes/app_colors.dart` | `AppColors.primaryColor = Colors.deepPurple.shade900`, `AppColors.backgroundColor = Colors.grey.shade900` (ambos `static`). |

## Dependências
- **Internas:** nenhuma.
- **Externas:** `material_ui` (em `app_colors.dart`).

## Módulos relacionados
- `env.dart`: `data/datasources/implementations/*`, `data/models/*` (URLs de imagem), `presentation/pages/login_page.dart` (`signupUrl`).
- `storage_keys.dart`: `data/datasources/implementations/{auth,user}_implementation.dart`, `data/repositories/auth_api.dart`.
- `app_colors.dart`: `presentation/pages/*`, `presentation/widgets/content_detail.dart`.

## Pontos de entrada
- `Environment.production`, `StorageKeys`, `AppColors`.

## Fluxos importantes
- Build: `flutter run --dart-define=TOKEN=<...> --dart-define=API_KEY=<...>`. Valores ausentes resultam em strings vazias e falha de todas as requisições.

## Arquivos críticos
- `env.dart`, `storage_keys.dart`.

## Observações técnicas e débitos
- **[Débito]** Apenas um ambiente (`production`); não há separação dev/staging.
- **[Débito]** `AppColors` não cobre todas as cores: várias telas usam `Colors.grey.shade900`, `Colors.white`, `Colors.deepPurple.shade900` diretamente.
- **[Risco S2]** Valores de `--dart-define` ficam embutidos no binário.
