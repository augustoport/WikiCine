# `lib/presentation/pages/` — Telas

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6, 7.1 · Fluxos de negócio: [`OBJETIVO_DO_SISTEMA.md`](../../../docs/OBJETIVO_DO_SISTEMA.md) seção 4.

## Objetivo
Compor as telas do app a partir de widgets, cubits e controllers.

## Responsabilidade principal
Obter cubits/controllers do locator, disparar carregamentos no `initState`, renderizar estados e navegar.

## Funcionalidades existentes
| Arquivo | Tela | Estado usado | Ações / navegação |
|---|---|---|---|
| `login_page.dart` | `LoginPage` — logo, campos usuário/senha, link de cadastro TMDB, botão Login | `LoginController` | Valida campos vazios; login → `pushReplacement(HomePage)`; link → `launchUrl(Environment.production.signupUrl)`; `initState` → `checkExistingSession()` |
| `home_page.dart` | `HomePage` — AppBar "WikiCine", busca, grid, barra inferior Movie/TV; `DrawerWidget` (avatar, nome, Profile, Settings, Exit) | `HomeCubit`, `HomeController`, `LoginController` | Carrega filmes; alterna Movie/TV; busca; Drawer: Profile → `ProfilePage`, Settings → `getIt<HomeCubit>().getTvShows()`, Exit → logout + `LoginPage` |
| `movie_detail_page.dart` | `MovieDetailPage(movieId)` | `MovieCubit` | Renderiza `ContentDetail(type: "movie")` ou "Error" |
| `tv_show_detail_page.dart` | `TvShowDetailPage(id)` | `SerieCubit` | Renderiza `ContentDetail(type: 'tv')` ou "Erro" |
| `profile_page.dart` | `ProfilePage` + `ProfileHeader` + `Favorites` | `ProfileCubit`, `LoginController` | Lista favoritos; tap → `MovieDetailPage`; voltar |

Todas as pages obtêm cubits/controllers com `getIt<T>()`.

## Dependências
- **Internas:** `core/locator.dart`, `core/shared/{env,themes/app_colors}.dart`, `presentation/bloc/*`, `presentation/controllers/*`, `presentation/widgets/*`, `domain/entities/{movie,user}.dart`.
- **Externas:** `material_ui`, `flutter_bloc`, `url_launcher`.

## Módulos relacionados
- `widgets/content_list.dart` importa `movie_detail_page.dart` e `tv_show_detail_page.dart` (navegação a partir do widget).

## Pontos de entrada
`LoginPage` (home do app).

## Fluxos importantes
Ver o mapa de navegação em [`../README.md`](../README.md).

## Arquivos críticos
- `home_page.dart` (maior arquivo de tela; contém também o Drawer).

## Observações técnicas e débitos
- **[Bug B2]** O item "Settings" usa uma nova instância de `HomeCubit`, então não tem efeito visível.
- **[Bug B7]** `Image.network("")` sem `errorBuilder` no Drawer e no `ProfileHeader` quando não há avatar. **Hipótese:** exibe erro de imagem.
- **[Débito]** `LoginPage` não redireciona para a Home quando há sessão válida.
- **[Débito]** `LoginPage` não reconstrói ao mudar `isLoading` (não usa `ListenableBuilder`). **Hipótese:** o spinner do botão não aparece durante o login.
- **[Débito]** Cubits não são fechados em `dispose()`.
- **[Débito]** Cores fixas `Colors.grey.shade900` nas telas de detalhe em vez de `AppColors`.
- **[Débito]** `ProfilePage`: `BlocBuilder` dentro de `Column` sem `Expanded`.
- **[Débito]** Rótulos em inglês ("Profile", "Settings", "Exit") e português misturados.
