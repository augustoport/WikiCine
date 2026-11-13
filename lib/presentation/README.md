# `lib/presentation/` — Camada de Apresentação

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../docs/ARQUITETURA_DO_SISTEMA.md) seções 2, 3 (R2, R3), 6, 7.

## Objetivo
Exibir a interface e gerenciar o estado das telas.

## Responsabilidade principal
Transformar ações do usuário em chamadas de casos de uso e estados em widgets.

## Submódulos
| Pasta | Conteúdo | README |
|---|---|---|
| `bloc/` | `HomeCubit`, `MovieCubit`, `SerieCubit`, `ProfileCubit` + estados | [bloc](./bloc/README.md) |
| `controllers/` | `LoginController` (ChangeNotifier), `HomeController` | [controllers](./controllers/README.md) |
| `pages/` | Login, Home (+Drawer), MovieDetail, TvShowDetail, Profile | [pages](./pages/README.md) |
| `widgets/` | Componentes reutilizáveis | [widgets](./widgets/README.md) |

## Mapa de navegação
```
LoginPage ──(login ok, pushReplacement)──► HomePage
HomePage ──(tap card filme)──► MovieDetailPage
HomePage ──(tap card série)──► TvShowDetailPage
HomePage.Drawer ──Profile──► ProfilePage ──(tap favorito)──► MovieDetailPage
HomePage.Drawer ──Exit (pushReplacement)──► LoginPage
```

## Dependências
- **Internas:** `core/locator.dart` (só nas pages), `core/shared/{env,themes/app_colors}.dart`, `domain/usecases/*`, `domain/entities/*`. **Não importa `data/`** (R3) nem repositórios (R2).
- **Externas:** `material_ui`, `bloc`, `flutter_bloc`, `cached_network_image`, `intl`, `url_launcher`.

## Módulos relacionados
- `core/locator.dart` registra todos os cubits e controllers, injetando os casos de uso.

## Pontos de entrada
`LoginPage` (home do `MaterialApp`).

## Fluxos importantes
Ver seções 6.2–6.8 da arquitetura.

## Arquivos críticos
- `pages/home_page.dart`, `bloc/movie_detail/movie_cubit.dart`, `controllers/login_controller.dart`, `widgets/content_detail.dart`.

## Observações técnicas e débitos
- **[Débito]** Não usa `BlocProvider`; cubits não são fechados (`close()`).
- **[Débito]** Textos da UI misturam português e inglês; sem i18n.
