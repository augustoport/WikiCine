# `lib/core/shared/` — Configuração compartilhada

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 3 (R7), 7.5.

## Objetivo
Centralizar constantes de ambiente e de tema usadas por várias camadas.

## Responsabilidade principal
`env.dart` é a **única** fonte de URLs e credenciais da API TMDB.

## Funcionalidades existentes
| Arquivo | Conteúdo |
|---|---|
| `env.dart` | `enum Environment { production }` com `baseUrl = https://api.themoviedb.org/3`, `mediaUrl = https://media.themoviedb.org/t/p/w400`, `token = String.fromEnvironment('TOKEN')`, `apiKey = String.fromEnvironment('API_KEY')`. |
| `themes/app_colors.dart` | `AppColors.primaryColor = Colors.deepPurple.shade900`, `AppColors.backgroundColor = Colors.grey.shade900` (ambos `static`). |
| `routes.dart` | **Vazio.** |

## Dependências
- **Internas:** nenhuma.
- **Externas:** `material_ui` (em `app_colors.dart`).

## Módulos relacionados
- `env.dart` é importado por: `data/datasources/implementations/*`, `data/models/*` (montagem de URLs de imagem), `core/services/*`.
- `app_colors.dart` é importado por: `core/locator.dart`, `presentation/pages/*`, `presentation/widgets/content_detail.dart`.

## Pontos de entrada
- `Environment.production`
- `AppColors.primaryColor` / `AppColors.backgroundColor`

## Fluxos importantes
- Build: `flutter run --dart-define=TOKEN=<...> --dart-define=API_KEY=<...>`. Valores ausentes resultam em strings vazias e falha de todas as requisições.

## Arquivos críticos
- `env.dart`

## Observações técnicas e débitos
- **[Órfão]** `routes.dart` está vazio; a navegação é feita com `MaterialPageRoute` direto nas telas.
- **[Débito]** Apenas um ambiente (`production`); não há separação dev/staging.
- **[Débito]** `AppColors` não cobre todas as cores: várias telas usam `Colors.grey.shade900`, `Colors.white`, `Colors.deepPurple.shade900` diretamente.
- **[Risco S2]** Valores de `--dart-define` ficam embutidos no binário.
- **Proposta (não existe hoje):** criar `storage_keys.dart` para as chaves `'tmdb_session_id'` e `'account_id'`, hoje duplicadas como literais.
