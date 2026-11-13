# `lib/presentation/pages/` — Telas

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6, 7.1 · Fluxos de negócio: [`OBJETIVO_DO_SISTEMA.md`](../../../docs/OBJETIVO_DO_SISTEMA.md) seção 4.

## Objetivo
Compor as telas do app a partir de widgets, cubits e controllers.

## Responsabilidade principal
Disparar carregamentos no `initState`, renderizar estados e navegar.

## Funcionalidades existentes
| Arquivo | Tela | Estado usado | Ações / navegação |
|---|---|---|---|
| `login_page.dart` | `LoginPage` — logo, campos usuário/senha, link de cadastro TMDB, botão Login | `LoginController` | Valida campos vazios; login → `pushReplacement(HomePage)`; link → `launchUrl(themoviedb.org/signup)`; `initState` → `checkExistingSession()` |
| `home_page.dart` | `HomePage` — AppBar "WikiCine", busca, grid, barra inferior Movie/TV; `DrawerWidget` (avatar, nome, Profile, Settings, Exit) | `HomeCubit`, `HomeController`, `LoginController` | Carrega filmes; alterna Movie/TV; busca; Drawer: Profile → `ProfilePage`, Settings → `getIt<HomeCubit>().getTvShows()`, Exit → logout + `LoginPage` |
| `movie_detail_page.dart` | `MovieDetailPage(movieId)` | `MovieCubit` | Renderiza `ContentDetail(type: "movie")` ou "Error" |
| `tv_show_detail_page.dart` | `TvShowDetailPage(id)` | `SerieCubit` (instanciado direto) | Renderiza `ContentDetail(type: 'tv')` ou "Erro" |
| `profile_page.dart` | `ProfilePage` + `ProfileHeader` + `Favorites` | `ProfileCubit`, `LoginController` | Lista favoritos; tap → `MovieDetailPage`; voltar |

## Dependências
- **Internas:** `core/locator.dart`, `core/shared/themes/app_colors.dart`, `presentation/bloc/*`, `presentation/controllers/*`, `presentation/widgets/*`, `domain/entities/{movie,user}.dart`.
- **Externas:** `material_ui`, `flutter_bloc`, `url_launcher`.

## Módulos relacionados
- `widgets/content_list.dart` importa `movie_detail_page.dart` e `tv_show_detail_page.dart` (navegação a partir do widget).

## Pontos de entrada
`LoginPage` (home do app).

## Fluxos importantes
Ver mapa de navegação em [`../README.md`](../README.md).

## Arquivos críticos
- `home_page.dart` (maior arquivo de tela; contém também o Drawer).

## Observações técnicas e débitos
- **[Bug B2]** Item "Settings" usa nova instância de `HomeCubit` → sem efeito visível.
- **[Bug B7]** `Image.network("")` sem `errorBuilder` no Drawer e no `ProfileHeader` quando não há avatar. **Hipótese:** exibe erro de imagem.
- **[Débito]** `LoginPage` não redireciona para a Home quando há sessão válida.
- **[Débito]** `LoginPage` não reconstrói ao mudar `isLoading` (não usa `ListenableBuilder`). **Hipótese:** o spinner do botão não aparece durante o login.
- **[Débito]** Cubits não são fechados em `dispose()`; `HomePage`/`DrawerWidget` têm `dispose` vazio.
- **[Débito]** Variáveis `appColors` sem uso em `movie_detail_page.dart` e `tv_show_detail_page.dart`; cores fixas `Colors.grey.shade900`.
- **[Débito]** `ProfilePage`: `BlocBuilder` dentro de `Column` sem `Expanded`; o estado de erro inclui o `ProfileInitial`.
- **[Débito]** Rótulos em inglês ("Profile", "Settings", "Exit") e português misturados.
- `tv_show_detail_page.dart` tem `// ignore_for_file: public_member_api_docs, sort_constructors_first`.
