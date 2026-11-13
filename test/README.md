# `test/` — Testes automatizados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../docs/ARQUITETURA_DO_SISTEMA.md) seções 7.1, 7.4 (S12), 9, 10.

## Objetivo
Abrigar os testes unitários e de widget do app (`flutter test`). O teste de integração fica em [`integration_test/`](../integration_test/app_flow_test.dart).

## Estrutura (espelha `lib/`)
| Caminho | Tipo | Cobertura |
|---|---|---|
| `domain/usecases/auth_usecases_test.dart` | Unitário | `LoginUseCase`, `LogoutUseCase` |
| `domain/usecases/user_usecases_test.dart` | Unitário | `GetCurrentUserUseCase`, `GetUserFavoritesUseCase` |
| `domain/usecases/movie_usecases_test.dart` | Unitário | `GetMoviesUseCase`, `SearchMoviesUseCase`, `GetMovieDetailsUseCase`, `GetMovieCrewUseCase` (filtro `Acting` + diretor) |
| `domain/usecases/tv_show_usecases_test.dart` | Unitário | `GetTvShowsUseCase`, `SearchTvShowsUseCase`, `GetTvShowDetailsUseCase`, `GetTvShowCrewUseCase` |
| `presentation/pages/login_page_test.dart` | Widget | Campos, senha oculta, validação de vazios, credencial inválida, login → Home |
| `presentation/pages/home_page_test.dart` | Widget | Lista de filmes, loading, alternância Movie/TV, busca, erros, navegação para detalhes; `DrawerWidget` (nome, sessão, Profile, Exit/logout) |
| `presentation/pages/profile_page_test.dart` | Widget | Cabeçalho do usuário, favoritos, lista vazia, erro, tap → detalhe, voltar |
| `presentation/pages/detail_pages_test.dart` | Widget | `MovieDetailPage` (elenco filtrado, diretor, favorito, erros) e `TvShowDetailPage` |
| `presentation/widgets/content_detail_test.dart` | Widget | `ContentDetail` (filme/série, valores ausentes, favorito) e `CastCard` |
| `presentation/widgets/content_list_test.dart` | Widget | `ContentList`/`MovieCard`, pull-to-refresh e navegação por tipo |

### Helpers (`helpers/`)
| Arquivo | Papel |
|---|---|
| `fakes.dart` | Repositórios falsos (`Fake{Auth,Movie,Tv,User}Repository`): registram chamadas em `calls`, falham sob demanda via `failing.add('<método>')` e simulam latência com `delay`. |
| `fixtures.dart` | Entidades de exemplo (usuário, filmes, séries, elenco, diretor). |
| `test_locator.dart` | `setupTestLocator()` — espelha `setupLocator()` trocando os repositórios por fakes; devolve `TestDeps`. |
| `fake_image_http.dart` | `FakeImageHttpOverrides` — responde PNG 1x1 a qualquer requisição, para `Image.network` funcionar nos testes. |
| `pump_app.dart` | `pumpApp`/`pumpInScaffold` com tela lógica de 600x900. |

## Como executar
```bash
flutter test                                       # unitários + widget
flutter test integration_test -d <device-id>       # integração (emulador/aparelho)
```

## Decisões
- **Sem biblioteca de mocks.** Os contratos de repositório são pequenos; fakes escritos à mão evitam dependências e deixam os cenários legíveis.
- **Testes de widget usam o `getIt` real** com dependências falsas, porque as pages resolvem cubits/controllers via `getIt<T>()`.
- **Imagens nulas nas fixtures.** `MovieCard` usa `CachedNetworkImage`, que depende de plugins (sqflite/path_provider) indisponíveis em `flutter test`.
- **Tela de 600x900.** A fonte de teste (Ahem) desenha cada caractere como um quadrado; em 360dp algumas linhas acusariam overflow que não ocorre com a Roboto.

## Observações técnicas e débitos
- **[Bug B3]** `content_detail_test.dart` tem um teste com `skip: true` para filme sem data de lançamento; basta remover o `skip` quando o bug for corrigido.
- Bugs **B8, B9 e B10** (seção 7.1 da arquitetura) foram encontrados por esta suíte e corrigidos.
- **Ainda sem cobertura:** `data/models` (`fromMap`), datasources/repositórios (Dio), cubits e controllers isolados (exercitados apenas indiretamente pelos testes de widget). Não há CI.
- O teste de integração não acessa a API do TMDB: usa `MyApp` real com repositórios falsos. Um teste contra a API real exigiria `--dart-define=TOKEN/API_KEY` e credenciais de uma conta de teste, e seria instável (rede, dados mutáveis).
