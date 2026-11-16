# Implementation Plan: Modo visitante (guest)

**Spec**: [spec.md](./spec.md) · **Branch sugerida**: `001-modo-visitante` · **Criado**: 2026-11-16 · **Status**: Proposto

**Ordem obrigatória**: (1) escrever **todos** os testes, de unidade e de widget → (2) confirmar que falham pelo motivo certo → (3) implementar o código até todos passarem → (4) atualizar a documentação.

---

## 1. Resumo técnico

"Visitante" é o usuário que está dentro do app **sem sessão salva**. Essa é a mesma regra que o detalhe de filme já usa para esconder o coração (`IsLoggedInUseCase`), e o plano a adota como **fonte única** em todo o app:

- **Nada é gravado:** não existe flag de visitante no aparelho. Ao reabrir o app sem sessão, a tela de login aparece, o que cumpre a FR-005 sem código extra.
- **Login:** a tela ganha o botão "Continuar sem login", visível apenas quando não há sessão (FR-001). O toque leva à Home sem chamar nenhum caso de uso de conta.
- **Menu lateral:** sem sessão, o menu mostra "Olá, visitante", esconde "Profile" e troca "Exit" por "Entrar" (FR-007, FR-011).
- **Perfil:** passa a verificar a sessão. Sem sessão, não busca favoritos e devolve o visitante à Home (FR-010, FR-012).
- **Detalhe de filme:** já cumpre a FR-006 (coração oculto). Nada muda.

Não há caso de uso, repositório nem datasource novos: `IsLoggedInUseCase` já existe e já tem teste.

## 2. Contexto e restrições (de `docs/`)

| Fonte | Impacto no plano |
|---|---|
| Diretriz 3 (dependências) | `presentation → domain` apenas. O estado de visitante fica no `LoginController` (apresentação), calculado pelo `IsLoggedInUseCase` (domínio). |
| Diretriz 4 (injeção por construtor) | `LoginController` e `ProfileCubit` recebem o `IsLoggedInUseCase` pelo construtor; `getIt` continua só no locator e nas pages. |
| Diretriz 8 (estados do Cubit) | `ProfileCubit` ganha um estado explícito, `ProfileRestricted`, em vez de reaproveitar `ProfileError`. |
| Diretriz 10 (consistência documental) | READMEs de `controllers/`, `bloc/`, `pages/` e `test/`, além de `docs/`, são atualizados no mesmo PR. |
| D30 (`go_router`) não implementado | Sem guard central: a proteção do Perfil fica na própria página (via cubit). Quando o `go_router` chegar, a regra migra para o guard (I9). |
| D5 (login automático) não implementado | Com sessão salva, a tela de login continua aparecendo, mas sem o botão de visitante. Fora do escopo. |
| D13 (i18n) não implementado | Os textos novos ("Continuar sem login", "Entrar", "Olá, visitante") ficam fixos no código, como os demais. |

## 3. Desenho

### 3.1 `LoginController` (`presentation/controllers/login_controller.dart`)
| Membro | Comportamento |
|---|---|
| construtor | Recebe também `IsLoggedInUseCase isLoggedInUseCase`. |
| `bool hasSession` (novo, inicia `false`) | Resultado do último `IsLoggedInUseCase`. |
| `bool get isGuest` (novo) | `!hasSession`. |
| `checkExistingSession()` | Chama `IsLoggedInUseCase`. **Sem sessão:** `hasSession = false`, `currentUser = null` e **não** chama `GetCurrentUserUseCase` (FR-012). **Com sessão:** `hasSession = true` e carrega o usuário como hoje. |
| `continueAsGuest()` (novo) | `hasSession = false`, `currentUser = null`, limpa os campos de usuário e senha, `notifyListeners()`. Não chama nenhum caso de uso e não grava nada. |
| `login()` | Em caso de sucesso, também `hasSession = true`. |
| `logout()` | Também `hasSession = false`. |

### 3.2 `LoginPage`
- Novo botão secundário **"Continuar sem login"**, abaixo do botão "Login", exibido quando `!loginController.hasSession`. A página passa a ouvir o controller (`ListenableBuilder`) para reagir ao resultado de `checkExistingSession`.
- Toque: `continueAsGuest()` e depois `Navigator.pushReplacement(HomePage)`.
- Login com sucesso continua levando à Home (FR-009, "sempre a Home"). Em caso de falha, a mensagem atual aparece e o botão de visitante continua visível (US3, cenário 3).

### 3.3 `DrawerWidget` (`home_page.dart`)
- `initState`: se `currentUser == null`, chama `checkExistingSession()`, como hoje. Para o visitante, isso já não busca dados de conta.
- Se `isGuest`:
  - **Cabeçalho:** `Icon(Icons.person)` e "Olá, \nvisitante", sem `Image.network`.
  - **Itens:** sem "Profile"; "Settings" continua (premissa da spec); no rodapé, "Entrar" (`Icons.login`) no lugar de "Exit".
  - **"Entrar":** `Navigator.pushAndRemoveUntil(LoginPage, (_) => false)`. Não chama logout, porque não há sessão.
- Logado: igual a hoje.

### 3.4 `ProfileCubit` e `ProfilePage`
- `ProfileCubit` recebe `IsLoggedInUseCase`. `initProfile()`: sem sessão → emite `ProfileRestricted` e **não** chama `GetUserFavoritesUseCase`; com sessão → fluxo atual.
- Novo estado `ProfileRestricted` em `profile_states.dart`.
- `ProfilePage`: um `BlocListener` (ou o próprio `BlocBuilder` com `addPostFrameCallback`) reage a `ProfileRestricted` com `Navigator.pushAndRemoveUntil(HomePage, (_) => false)` (FR-010: "vai para a Home").

### 3.5 Locator (`core/locator.dart`) e `test/helpers/test_locator.dart`
- Injetar `getIt<IsLoggedInUseCase>()` no `LoginController` e no `ProfileCubit`, nos dois arquivos.

### 3.6 Sem mudança
`MovieCubit`/`MovieDetailPage` (FR-006 já atendida), `HomeCubit`, os casos de uso, os repositórios e os datasources.

## 4. Fase 1 — Testes (escrever todos antes de qualquer código)

### 4.1 Testes de unidade

**`test/presentation/controllers/login_controller_test.dart`** (novo)
| # | Cenário | Requisito |
|---|---|---|
| U1 | Sem sessão: `checkExistingSession` → `isGuest == true`, `currentUser == null`, e `auth.calls` não contém `getCurrentUser` | FR-012, US2 |
| U2 | Com sessão: `checkExistingSession` → `isGuest == false` e `currentUser` carregado | Edge "sessão salva" |
| U3 | `continueAsGuest()` → `isGuest == true`, campos limpos e nenhuma chamada a repositório (`auth.calls` vazio) | FR-002, FR-004, FR-005 |
| U4 | `continueAsGuest()` notifica os listeners | US1 |
| U5 | `login()` com sucesso depois do modo visitante → `isGuest == false` e `currentUser` definido | FR-009, US3 |
| U6 | `login()` com falha depois do modo visitante → continua `isGuest == true` | US3 cenário 3 |
| U7 | `logout()` → `isGuest == true` | Edge "logout" |

**`test/presentation/bloc/profile_cubit_test.dart`** (novo)
| # | Cenário | Requisito |
|---|---|---|
| U8 | Com sessão: `initProfile` → `ProfileLoading`, `ProfileSuccess(favorites)` | regressão |
| U9 | Sem sessão: `initProfile` → `ProfileRestricted` e `user.calls` vazio (favoritos não consultados) | FR-010, FR-012 |
| U10 | Com sessão e favoritos falhando → `ProfileError` | regressão |

> `IsLoggedInUseCase` já é coberto por `test/domain/usecases/auth_usecases_test.dart`. O guest de `MovieCubit` já é coberto por `test/presentation/bloc/movie_cubit_test.dart`.

### 4.2 Testes de widget

**`test/presentation/pages/login_page_test.dart`** (alterado)
| # | Cenário | Requisito |
|---|---|---|
| W1 | Sem sessão: exibe "Login" e "Continuar sem login" | FR-001, US1-1 |
| W2 | Com sessão salva: "Continuar sem login" não é exibido | FR-001 |
| W3 | Tocar em "Continuar sem login" abre a Home com "Interestelar", sem chamada de `login` | FR-002, FR-003, SC-001 |
| W4 | Após login com falha, "Continuar sem login" continua visível | US3-3 |

**`test/presentation/pages/home_page_test.dart`**, grupo `DrawerWidget` (alterado)
| # | Cenário | Requisito |
|---|---|---|
| W5 | Visitante: cabeçalho com `Icons.person` e "visitante"; nenhum `Image.network` no cabeçalho | FR-011 |
| W6 | Visitante: "Profile" e "Exit" ausentes; "Entrar" e "Settings" presentes | FR-007, premissa |
| W7 | Visitante: tocar em "Entrar" abre a `LoginPage` e remove a Home da pilha; `logout` não é chamado | FR-008, US3-1 |
| W8 | Visitante: abrir o menu não chama `getCurrentUser` | FR-012, SC-003 |
| W9 | **Atualizar** o teste existente "sem sessão, exibe 'Usuário' como nome padrão": passa a esperar "visitante" | FR-011 |
| — | Os testes de usuário logado ("Profile", "Exit"/logout, nome) continuam iguais, com `deps.auth.currentUser` definido | regressão |

**`test/presentation/pages/home_page_test.dart`**, grupo `HomePage` (alterado)
| # | Cenário | Requisito |
|---|---|---|
| W10 | Visitante: lista de filmes, alternância para séries, busca e abertura de detalhe funcionam (reaproveita os cenários existentes, que já rodam sem sessão; incluir uma asserção explícita de que nenhuma chamada de conta foi feita) | FR-003, SC-002 |

**`test/presentation/pages/profile_page_test.dart`** (alterado)
| # | Cenário | Requisito |
|---|---|---|
| W11 | Visitante que abre o `ProfilePage` é levado à Home, e os favoritos não são consultados | FR-010, FR-012 |
| — | Os testes existentes passam a definir `deps.auth.currentUser` (usuário logado) no `setUp` | regressão |

**`test/presentation/pages/detail_pages_test.dart`**: sem alteração. O grupo "visitante (guest)" já cobre a FR-006 no detalhe de filme.

### 4.3 Teste de integração

**`integration_test/app_flow_test.dart`**: novo `testWidgets` **"visitante → catálogo → entrar → logado"**:
1. Abrir `MyApp` sem sessão → tocar em "Continuar sem login" → Home com filmes.
2. Abrir um filme → coração ausente → voltar.
3. Abrir o menu → "Olá, visitante", sem "Profile" → tocar em "Entrar" → `LoginPage`.
4. Fazer login válido → Home → abrir o menu → nome do usuário, "Profile" e "Exit" presentes.

Esse teste roda apenas em aparelho, emulador ou desktop (`flutter test integration_test -d <device>`). Neste ambiente de nuvem só é validado pelo `flutter analyze`.

### 4.4 Ajustes de helpers
- `test/helpers/test_locator.dart`: injetar `IsLoggedInUseCase` no `LoginController` e no `ProfileCubit`. Esta é a única alteração de "produção" que os testes exigem antes de compilar; ver 4.5.

### 4.5 Checkpoint "vermelho"
- Rodar `flutter test`. Resultado esperado: **falhas** nos testes novos. Os novos `login_controller_test` e `profile_cubit_test`, e o `test_locator` alterado, **não compilam** até que existam `isGuest`, `continueAsGuest`, `ProfileRestricted` e os novos parâmetros de construtor. Em Dart, erro de compilação conta como "vermelho".
- Os testes de widget que só procuram textos ("Continuar sem login", "Entrar", "visitante") compilam e falham por asserção.
- Registrar a lista de falhas no PR antes de iniciar a Fase 2.

## 5. Fase 2 — Implementação (só depois da Fase 1 completa)

| Passo | Arquivo | Alteração | Testes que passam a verde |
|---|---|---|---|
| I1 | `lib/presentation/controllers/login_controller.dart` | `IsLoggedInUseCase` no construtor, `hasSession`, `isGuest`, `continueAsGuest()`, ajustes em `checkExistingSession`, `login` e `logout` | U1–U7 |
| I2 | `lib/presentation/bloc/profile/profile_states.dart`, `profile_cubit.dart` | estado `ProfileRestricted`; `IsLoggedInUseCase` no construtor; verificação em `initProfile` | U8–U10 |
| I3 | `lib/core/locator.dart` | injetar `IsLoggedInUseCase` no `LoginController` e no `ProfileCubit` | (compilação do app) |
| I4 | `lib/presentation/pages/login_page.dart` | botão "Continuar sem login" + `ListenableBuilder` | W1–W4 |
| I5 | `lib/presentation/pages/home_page.dart` (`DrawerWidget`) | cabeçalho e itens do visitante, ação "Entrar" | W5–W10 |
| I6 | `lib/presentation/pages/profile_page.dart` | reação a `ProfileRestricted` → Home | W11 |
| I7 | — | `flutter analyze` sem novos avisos e `flutter test` 100% verde | todos |

## 6. Fase 3 — Documentação

- `docs/OBJETIVO_DO_SISTEMA.md`: fluxos F1 e F6, tabela de funcionalidades, status de D20, D21 e D22 → implementado. Registrar as respostas da spec como decisões **D34** (pós-login → Home), **D35** (área restrita → Home) e **D36** (cabeçalho "Olá, visitante"), se o mantenedor aprovar.
- `docs/ARQUITETURA_DO_SISTEMA.md`: novo fluxo "Modo visitante" na seção 6; atualizar 6.3 (sessão), 6.7 (perfil com `ProfileRestricted`) e 6.9 (injeções do locator).
- READMEs: `lib/presentation/controllers`, `lib/presentation/bloc`, `lib/presentation/pages`, `test/`.
- `specs/001-modo-visitante/spec.md` → `Status: Implemented`; `specs/README.md` atualizado.

## 7. Rastreabilidade requisito → teste

| Requisito | Testes |
|---|---|
| FR-001 | W1, W2, W4 |
| FR-002 | U3, W3 |
| FR-003 | W3, W10, integração |
| FR-004 | U3 |
| FR-005 | U3 (nada é gravado; reabrir = nova instância sem sessão), W2 |
| FR-006 | `detail_pages_test` (grupo visitante, já existe), `movie_cubit_test` (já existe) |
| FR-007 | W6 |
| FR-008 | W7, integração |
| FR-009 | U5, integração |
| FR-010 | U9, W11 |
| FR-011 | W5, W9 |
| FR-012 | U1, U9, W8, W11 |
| SC-001 | W3 (um toque) |
| SC-002 | W6, W10, `detail_pages_test` |
| SC-003 | U1, U9, W8 |
| SC-004 | W2 + desenho (sem persistência) |
| SC-005 | W7 (menu → "Entrar" = 2 toques) |

## 8. Riscos e pontos de atenção

| Risco | Mitigação |
|---|---|
| Na abertura da tela de login, `hasSession` começa `false` até `checkExistingSession` terminar, então o botão "Continuar sem login" pode piscar quando há sessão salva. | Aceito nesta fase (leitura local, rápida). Será resolvido de vez com D5 (splash e login automático). |
| Uma sessão salva mas inválida (ex.: expirada) é tratada como "logado" pelo `IsLoggedInUseCase`. | Coerente com o comportamento atual; o tratamento de sessão expirada é a D31. |
| "Settings" continua sem tela e com o bug B2 (troca a aba de outra instância). | Fora do escopo; o item continua visível para o visitante, conforme a premissa da spec. |
| Mistura de idiomas ("Exit" × "Entrar"). | Fica para a i18n (D13). |
| O teste de integração não roda neste ambiente de nuvem. | Validação por `flutter analyze`; execução local em emulador/aparelho. |

## 9. Estimativa de mudanças

- **Produção:** 7 arquivos alterados (`login_controller`, `profile_cubit`, `profile_states`, `locator`, `login_page`, `home_page`, `profile_page`) e nenhum arquivo novo.
- **Testes:** 2 arquivos novos (`login_controller_test`, `profile_cubit_test`), 4 alterados (`login_page_test`, `home_page_test`, `profile_page_test`, `test_locator`) e o teste de integração.
- **Documentação:** 2 documentos globais e 4 READMEs, além de `specs/`.
