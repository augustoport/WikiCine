# `lib/presentation/controllers/` — Controllers de UI

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 6.2, 6.3, 6.4, 6.8.

## Objetivo
Gerenciar estado de UI que não está em cubits: formulário e sessão de login, e campo de busca da Home.

## Responsabilidade principal
- `LoginController`: **estado global do usuário logado** (`currentUser`) e ações de login/logout.
- `HomeController`: decidir qual método do `HomeCubit` chamar a partir do texto de busca.

## Funcionalidades existentes
### `LoginController extends ChangeNotifier` (lazy singleton)
Construtor: `LoginController({loginUseCase, getCurrentUserUseCase, logoutUseCase})`.

| Membro | Descrição |
|---|---|
| `emailController`, `passwordController` | `TextEditingController`s do formulário (o "email" é na prática o **username** TMDB). |
| `isLoading`, `loadingDrawer`, `currentUser` | Estado observado por `LoginPage`, `DrawerWidget`, `ProfilePage`. |
| `login() → bool` | Chama `LoginUseCase`; `true` em sucesso, `false` em qualquer exceção. |
| `checkExistingSession()` | Chama `GetCurrentUserUseCase`; preenche `currentUser` se houver sessão. |
| `logout()` | Chama `LogoutUseCase`, limpa `currentUser` e os campos. |

### `HomeController` (factory)
| Membro | Descrição |
|---|---|
| `searchController` | Campo "Pesquisar" da Home. |
| `setList(search, homeCubit)` | Se o estado for `HomeMovie` → `getMovie`/`getMovies`; se `HomeTv` → `getTvShow`/`getTvShows`. |

## Dependências
- **Internas:** `domain/usecases/auth/*`, `domain/usecases/user/get_current_user_usecase.dart`, `domain/entities/user.dart`, `presentation/bloc/home/home_cubit.dart`.
- **Externas:** `material_ui`.

## Módulos relacionados
- `pages/login_page.dart`, `pages/home_page.dart` (`HomePage` e `DrawerWidget`), `pages/profile_page.dart`.

## Pontos de entrada
`getIt<LoginController>()`, `getIt<HomeController>()`.

## Fluxos importantes
Login, sessão existente e logout: seções 6.2, 6.3 e 6.8 da arquitetura.

## Arquivos críticos
- `login_controller.dart` (fonte única de `currentUser`).

## Observações técnicas e débitos
- **[Bug B4]** `setList` não faz nada quando o estado é `HomeLoading`/`HomeError`/`HomeInitial`.
- **[Débito]** Os controllers de texto nunca recebem `dispose()`; no singleton, o texto digitado persiste até o logout.
- **[Débito]** `LoginController` mistura estado de formulário com estado de sessão; candidato a separação (ex.: `SessionCubit`).
- **[Débito]** Erros de login não diferenciam credencial inválida de falha de rede.
- **[Débito]** Padrões de estado mistos na apresentação (ChangeNotifier aqui, Cubit em `bloc/`).
