# Implementation Plan: Modo visitante (guest)

**Spec**: [spec.md](./spec.md) · **Branch**: `001-modo-visitante` · **Criado**: 2026-11-16 · **Revisado**: 2026-11-16 (rodada 3: sessão de convidado do TMDB) · **Status**: Implementado (2026-11-17)

**Ordem obrigatória**: (1) escrever **todos** os testes, de unidade e de widget → (2) confirmar que falham pelo motivo certo → (3) implementar o código até todos passarem → (4) atualizar a documentação. A implementação só começa com a confirmação do mantenedor.

---

## 1. Resumo técnico

O app passa a ter três **modos de acesso**, calculados a partir do que está salvo no aparelho:

| Modo | Condição | Ao abrir o app |
|---|---|---|
| `user` | há `session_id` de conta | Home, logado (antecipa D5) |
| `guest` | há `guest_session_id` **e** a validade (`expires_at`) não passou | Home, visitante |
| `none` | nada válido (sessão de convidado expirada é apagada) | Login |

- **"Continuar sem login"** chama `GET /authentication/guest_session/new` (resposta conferida em 2026-11-16: `{success, guest_session_id, expires_at: "2026-11-17 23:35:17 UTC"}`, cerca de 24h), grava o id e a validade no `FlutterSecureStorage` e abre a Home. Se já existe uma sessão de convidado válida, ela é reaproveitada sem nova chamada.
- **Tela de carregamento** (`SplashPage`) nova: decide entre Login e Home sem mostrar o login de passagem.
- **Travas do visitante** (perfil, favoritos, watchlist e avaliação): continuam baseadas no `IsLoggedInUseCase`, que só é `true` com sessão de **conta**. Para o visitante ele é `false`, então o coração do detalhe de filme (já existente) e o Perfil ficam travados sem mudar o `MovieCubit`.
- **Login com sucesso** apaga a sessão de convidado. **Logout** apaga tudo.
- O `guest_session_id` hoje só identifica o modo visitante: nenhuma chamada do catálogo usa essa sessão (ele usa o token do app, D18). Avaliação, que é o que a sessão de convidado permitiria, fica travada por decisão do mantenedor.

## 2. Contexto e restrições (de `docs/`)

| Fonte | Impacto no plano |
|---|---|
| Diretriz 3 (dependências) | `presentation → domain → data`. O modo de acesso é uma entidade de domínio (`AccessMode`); quem lê storage e TMDB é o `data`. |
| Diretriz 4 (injeção por construtor) | `LoginController` e `ProfileCubit` recebem os casos de uso pelo construtor; `getIt` só no locator e nas pages. |
| Diretriz 8 (estados do Cubit) | `ProfileCubit` ganha o estado explícito `ProfileRestricted`. |
| Diretriz 10 (consistência documental) | READMEs das camadas tocadas e `docs/` atualizados no mesmo PR. |
| Diretriz 11 (`/account` com `session_id`) | Não se aplica ao visitante: ele não faz chamadas `/account`. |
| D20 e D22 **revisadas** (rodada 3 da spec) | Sessão de convidado do TMDB passa a ser usada e lembrada enquanto válida. Registrar em `docs/` na Fase 3. |
| D5 (login automático) | Passa a ser implementada para sessão de conta, sem validar a sessão na rede (a validação fica com a D31). |
| D30 (`go_router`) não implementado | Sem guard central: `SplashPage` decide a rota inicial e a proteção do Perfil fica no cubit. Migram para o guard quando o `go_router` chegar (I9). |
| D13 (i18n) não implementado | Textos novos fixos no código. |

## 3. Desenho

### 3.1 Domínio
| Item | Alteração |
|---|---|
| `domain/entities/access_mode.dart` (novo) | `enum AccessMode { none, guest, user }`. |
| `AuthRepository` | Novos: `Future<void> startGuestSession()` (cria ou reaproveita) e `Future<AccessMode> getAccessMode()`. `isLoggedIn()` continua: `true` só com sessão de conta. `logout()` passa a apagar também a sessão de convidado. |
| `usecases/auth/start_guest_session_usecase.dart` (novo) | Delega a `startGuestSession`. |
| `usecases/auth/get_access_mode_usecase.dart` (novo) | Delega a `getAccessMode`. |

### 3.2 Dados
| Item | Alteração |
|---|---|
| `core/shared/storage_keys.dart` | `guestSessionId = 'tmdb_guest_session_id'`, `guestSessionExpiresAt = 'tmdb_guest_session_expires_at'`. |
| `data/models/guest_session_model.dart` (novo) | `id` e `expiresAt` (`DateTime` UTC). `fromJson` converte `"2026-11-17 23:35:17 UTC"`: `DateTime.parse` não aceita o sufixo ` UTC`, então ele é trocado por `Z` antes. |
| `AuthData` / `AuthImplementation` | `Future<GuestSessionModel> createGuestSession()` → `GET /authentication/guest_session/new`. |
| `AuthApi` | Recebe um relógio opcional (`DateTime Function() now`, padrão `DateTime.now`) para testar a validade. `getAccessMode`: conta → `user`; convidado válido → `guest`; convidado expirado ou ilegível → apaga as duas chaves e `none`; senão `none`. `startGuestSession`: se há convidado válido, não faz nada; senão chama `createGuestSession` e grava id e validade (ISO 8601). `login`: depois do sucesso, apaga as chaves de convidado. `logout`: apaga as quatro chaves. |

### 3.3 Apresentação
**`LoginController`**
| Membro | Comportamento |
|---|---|
| construtor | Recebe também `StartGuestSessionUseCase` e `GetAccessModeUseCase`. |
| `AccessMode accessMode` (novo, inicia `none`) | Último modo conhecido. |
| `bool get isGuest` (novo) | `currentUser == null && accessMode != AccessMode.user`. Considera o `currentUser` porque partes do app (e testes existentes) definem o usuário em memória sem passar pelo `checkExistingSession`. |
| `checkExistingSession()` | Chama `GetAccessModeUseCase`. Só com `user` chama `GetCurrentUserUseCase` (FR-012). |
| `Future<bool> continueAsGuest()` (novo) | `isLoading` durante a chamada; chama `StartGuestSessionUseCase`. Sucesso: `accessMode = guest`, `currentUser = null`, limpa os campos, `true`. Falha: `false`, modo inalterado. |
| `login()` | Sucesso: também `accessMode = user`. |
| `logout()` | Também `accessMode = none`. |

**`SplashPage`** (nova, `presentation/pages/splash_page.dart`) e `main.dart`
- `MyApp.home` passa a ser `SplashPage`. Ela mostra um `CircularProgressIndicator`, chama `checkExistingSession()` e faz `pushReplacement` para `HomePage` (`user` ou `guest`) ou `LoginPage` (`none`) (FR-005, FR-013, FR-014, FR-017).

**`LoginPage`**
- Botão secundário "Continuar sem login" abaixo de "Login", exibido quando `accessMode != user` (`ListenableBuilder`).
- Toque: `await continueAsGuest()`. Sucesso → `pushReplacement(HomePage)`. Falha → SnackBar vermelho "Não foi possível entrar como visitante" (FR-015).
- Login com sucesso continua indo para a Home.

**`DrawerWidget`** (`home_page.dart`)
- `initState` igual: se `currentUser == null`, `checkExistingSession()` (para o visitante, não busca dados de conta).
- `isGuest`: cabeçalho com `Icon(Icons.person)` e "Olá, \nvisitante", sem `Image.network`; sem "Profile"; "Settings" mantido; "Entrar" (`Icons.login`) no lugar de "Exit".
- "Entrar": `pushAndRemoveUntil(LoginPage, (_) => false)`, sem logout (a sessão de convidado é mantida, FR-008).

**`ProfileCubit` / `ProfilePage`**
- `ProfileCubit` recebe `IsLoggedInUseCase`. Sem sessão de conta → `ProfileRestricted`, sem consultar favoritos.
- `ProfilePage` reage a `ProfileRestricted` com `pushAndRemoveUntil(HomePage, (_) => false)` (FR-010).

### 3.4 Locator e `test/helpers/test_locator.dart`
- Registrar `StartGuestSessionUseCase` e `GetAccessModeUseCase`; injetá-los no `LoginController`; injetar `IsLoggedInUseCase` no `ProfileCubit`.

### 3.5 Sem mudança
`MovieCubit`, `MovieDetailPage`, `ContentDetail`, `HomeCubit`, `SerieCubit`, catálogo (`MovieData`, `TvData`), `UserData`.

## 4. Fase 1 — Testes (escrever todos antes de qualquer código)

Legenda de status: **escrito** (já está na branch e continua valendo), **ajustar** (escrito na rodada anterior, muda com a revisão), **novo**.

### 4.1 Helpers
| Arquivo | Alteração | Status |
|---|---|---|
| `test/helpers/fakes.dart` | `FakeAuthRepository`: `bool guestSession`; `startGuestSession` registra a chamada e liga `guestSession` (aceita `failing`); `getAccessMode` registra e devolve `user` se há `currentUser`, `guest` se `guestSession`, senão `none`; `login` com sucesso desliga `guestSession`; `logout` limpa os dois. | novo |
| `test/helpers/test_locator.dart` | Registrar os dois casos de uso novos e injetá-los, além do `IsLoggedInUseCase` no `ProfileCubit`. | ajustar |

### 4.2 Testes de unidade
**`test/domain/usecases/auth_usecases_test.dart`** (alterado)
| # | Cenário | Requisito | Status |
|---|---|---|---|
| D1 | `StartGuestSessionUseCase` delega ao repositório | FR-002 | novo |
| D2 | `StartGuestSessionUseCase` propaga a falha | FR-015 | novo |
| D3 | `GetAccessModeUseCase` devolve `user`, `guest` e `none` conforme o repositório | FR-005, FR-013 | novo |

**`test/data/models/guest_session_model_test.dart`** (novo)
| # | Cenário | Requisito | Status |
|---|---|---|---|
| M1 | `fromJson` lê `guest_session_id` e converte `"2026-11-17 23:35:17 UTC"` para `DateTime.utc(2026, 11, 17, 23, 35, 17)` | FR-004 | novo |

**`test/data/repositories/auth_api_test.dart`** (novo; `FakeAuthData` + `FlutterSecureStorage.setMockInitialValues` + relógio fixo)
| # | Cenário | Requisito | Status |
|---|---|---|---|
| A1 | Nada salvo → `none` | FR-001 | novo |
| A2 | Sessão de conta (com ou sem convidado) → `user` | FR-013, edge "ambas" | novo |
| A3 | Convidado com validade futura → `guest` | FR-005 | novo |
| A4 | Convidado expirado → `none` e as duas chaves apagadas | FR-014 | novo |
| A5 | `startGuestSession` sem sessão → chama `createGuestSession` e grava id e validade | FR-002, FR-004 | novo |
| A6 | `startGuestSession` com convidado válido → não chama `createGuestSession` | US3-3 | novo |
| A7 | `startGuestSession` com convidado expirado → cria outra | FR-014 | novo |
| A8 | `login` com sucesso apaga as chaves de convidado | FR-009 | novo |
| A9 | `logout` apaga conta e convidado | FR-016 | novo |
| A10 | `isLoggedIn` é `false` só com convidado | FR-006 | novo |

**`test/presentation/controllers/login_controller_test.dart`**
| # | Cenário | Requisito | Status |
|---|---|---|---|
| U1 | Sem sessão: `accessMode == none`, `isGuest`, chama `getAccessMode` e não `getCurrentUser` | FR-012 | ajustar (hoje espera `isLoggedIn`) |
| U2 | Sessão de conta: `accessMode == user`, carrega o usuário | FR-013 | ajustar |
| U2b | Sessão de convidado: `accessMode == guest`, `isGuest`, sem `getCurrentUser` | FR-005, FR-012 | novo |
| U3 | `continueAsGuest()`: chama `startGuestSession`, retorna `true`, `accessMode == guest`, campos limpos, sem `getCurrentUser` | FR-002 | ajustar (hoje espera nenhuma chamada) |
| U3b | `continueAsGuest()` com falha: retorna `false`, `accessMode == none` | FR-015 | novo |
| U4 | `continueAsGuest()` notifica os listeners | US1 | ajustar (passa a ser `async`) |
| U5 | Login com sucesso depois do visitante → `accessMode == user`, não é visitante | FR-009 | ajustar |
| U6 | Login com falha depois do visitante → continua visitante | US3-3 | escrito |
| U7 | `logout()` → `accessMode == none`, `isGuest` | FR-016 | ajustar |

**`test/presentation/bloc/profile_cubit_test.dart`**
| # | Cenário | Requisito | Status |
|---|---|---|---|
| U8 | Conta: Loading → Success | regressão | escrito |
| U9 | Sem sessão: `ProfileRestricted`, favoritos não consultados | FR-010, FR-012 | escrito |
| U10 | Conta e favoritos falhando: Error | regressão | escrito |
| U11 | Só sessão de convidado: `ProfileRestricted` | FR-006, FR-010 | novo |

### 4.3 Testes de widget
**`test/presentation/pages/splash_page_test.dart`** (novo)
| # | Cenário | Requisito | Status |
|---|---|---|---|
| S1 | Sem sessão → `LoginPage` | FR-001, SC-004 | novo |
| S2 | Sessão de convidado → `HomePage`; menu com "visitante" | FR-005, SC-004 | novo |
| S3 | Sessão de conta → `HomePage`; menu com o nome do usuário | FR-013, SC-004 | novo |
| S4 | Enquanto verifica (repositório com `delay`): indicador de carregamento, sem `LoginPage` | FR-017 | novo |

**`test/presentation/pages/login_page_test.dart`**
| # | Cenário | Requisito | Status |
|---|---|---|---|
| — | "verifica sessão existente ao abrir": espera `getAccessMode` e não `getCurrentUser` | FR-012 | ajustar (hoje espera `isLoggedIn`) |
| — | "com sessão salva, carrega o usuário ao abrir" | regressão | escrito |
| W1 | Sem sessão: "Login" e "Continuar sem login" | FR-001 | escrito |
| W2 | Sessão de conta: sem "Continuar sem login" | FR-001 | escrito |
| W3 | Tocar em "Continuar sem login" → `startGuestSession` e Home, sem `login` | FR-002, SC-001 | ajustar (incluir `startGuestSession`) |
| W3b | Falha ao iniciar convidado → SnackBar "Não foi possível entrar como visitante" e continua no login | FR-015 | novo |
| W4 | Login com falha mantém "Continuar sem login" | US3-3 | escrito |

**`test/presentation/pages/home_page_test.dart`**
| # | Cenário | Requisito | Status |
|---|---|---|---|
| W5–W8 | Menu do visitante (cabeçalho, itens, "Entrar", sem dados de conta), agora com `deps.auth.guestSession = true` | FR-007, FR-008, FR-011, FR-012 | ajustar |
| W7 | "Entrar" também mantém a sessão de convidado (`guestSession` continua `true`) | FR-008 | ajustar |
| W9 | Sem sessão, nome "visitante" | FR-011 | escrito |
| W10 | Visitante navega por filmes, séries, busca e detalhes sem dados de conta | FR-003, SC-002 | escrito (passa a usar `guestSession = true`) |

**`test/presentation/pages/profile_page_test.dart`**
| # | Cenário | Requisito | Status |
|---|---|---|---|
| W11 | Visitante (sem sessão de conta) que abre o Perfil vai para a Home | FR-010 | escrito |
| W11b | Com sessão de convidado ativa, o mesmo | FR-010 | novo |

**`test/presentation/pages/detail_pages_test.dart`**: sem alteração (o grupo "visitante" cobre a FR-006; `isLoggedIn` continua `false` para convidado).

### 4.4 Teste de integração (`integration_test/app_flow_test.dart`)
| Teste | Status |
|---|---|
| "login → filmes → … → logout": continua igual; agora passa pela `SplashPage` | escrito |
| "visitante → catálogo → entrar → logado": incluir `startGuestSession` em `deps.auth.calls` | ajustar |
| "reabrir com sessão de convidado → Home direto": `deps.auth.guestSession = true`, `pumpWidget(MyApp())` → `HomePage` sem `LoginPage` | novo |
| "reabrir com sessão de conta → Home direto" | novo |

Roda em aparelho, emulador ou desktop: `flutter test integration_test -d <device> --dart-define=...`.

### 4.5 Checkpoint "vermelho"
- `flutter test`: os arquivos que dependem da API nova (`test_locator`, controller, cubit, `auth_api`, model, splash) **não compilam**. Erro de compilação conta como vermelho.
- Para conferir que os testes de widget falham pelo motivo certo, rodá-los uma vez **antes** de alterar o `test_locator` (falhas por asserção) e registrar a lista no PR.
- Testes que já passam antes da implementação (regressões e W2) ficam listados no PR como esperados.

## 5. Fase 2 — Implementação (só depois da Fase 1 completa e da confirmação do mantenedor)

| Passo | Arquivos | Alteração | Testes que ficam verdes |
|---|---|---|---|
| I1 | `domain/entities/access_mode.dart`, `auth_repository.dart`, 2 casos de uso novos | contratos e casos de uso | D1–D3 |
| I2 | `storage_keys.dart`, `guest_session_model.dart`, `auth_data.dart`, `auth_implementation.dart`, `auth_api.dart` | sessão de convidado, validade, limpeza no login e logout | M1, A1–A10 |
| I3 | `login_controller.dart` | `accessMode`, `isGuest`, `continueAsGuest`, ajustes | U1–U7 |
| I4 | `profile_states.dart`, `profile_cubit.dart` | `ProfileRestricted` | U8–U11 |
| I5 | `core/locator.dart` | novas injeções | (compilação do app) |
| I6 | `splash_page.dart` (novo), `main.dart` | rota inicial | S1–S4 |
| I7 | `login_page.dart` | botão, SnackBar de falha | W1–W4 |
| I8 | `home_page.dart` (`DrawerWidget`) | menu do visitante | W5–W10 |
| I9 | `profile_page.dart` | `ProfileRestricted` → Home | W11, W11b |
| I10 | — | `dart format`, `flutter analyze` sem avisos, `flutter test` 100% verde; integração em emulador | todos |

## 6. Fase 3 — Documentação

- `docs/OBJETIVO_DO_SISTEMA.md`:
  - D20 e D22 revisadas (sessão de convidado do TMDB, lembrada enquanto válida; expirada → login).
  - D5 → implementado para sessão de conta (sem validação na rede).
  - Novas decisões, se aprovadas: **D34** pós-login → Home; **D35** área restrita → Home; **D36** cabeçalho "Olá, visitante"; **D37** visitante não avalia, apesar de a sessão de convidado permitir.
  - Fluxos F1 e F6 e tabela de funcionalidades.
- `docs/ARQUITETURA_DO_SISTEMA.md`: fluxo "Modo visitante" e "Abertura do app (SplashPage)" na seção 6; sessão (6.3) com as chaves novas; perfil (6.7); injeções (6.9).
- READMEs: `lib/core`, `lib/domain` (entities, repositories, usecases), `lib/data` (datasources, models, repositories), `lib/presentation` (controllers, bloc, pages), `test/`.
- `specs/001-modo-visitante/spec.md` → `Implemented`; `specs/README.md`.

## 7. Rastreabilidade requisito → teste

| Requisito | Testes |
|---|---|
| FR-001 | W1, W2, A1, S1 |
| FR-002 | D1, A5, U3, W3, integração |
| FR-003 | W3, W10, integração |
| FR-004 | M1, A5 |
| FR-005 | D3, A3, U2b, S2, integração (reabrir) |
| FR-006 | A10, U11, `detail_pages_test`, `movie_cubit_test` |
| FR-007 | W6 |
| FR-008 | W7, integração |
| FR-009 | A8, U5, integração |
| FR-010 | U9, U11, W11, W11b |
| FR-011 | W5, W9 |
| FR-012 | U1, U2b, U3, U9, W8, W10 |
| FR-013 | D3, A2, U2, S3, integração (reabrir) |
| FR-014 | A4, A7 |
| FR-015 | D2, U3b, W3b |
| FR-016 | A9, U7 |
| FR-017 | S4 |
| SC-001 | W3 |
| SC-002 | W6, W10, `detail_pages_test` |
| SC-003 | U1, U2b, U9, W8 |
| SC-004 | S1–S3, A3, A4 |
| SC-005 | W7 |

## 8. Riscos e pontos de atenção

| Risco | Mitigação |
|---|---|
| Formato de `expires_at` (`"... UTC"`) não é aceito por `DateTime.parse`. | Conversão no `GuestSessionModel`, coberta por M1. Valor ilegível no storage é tratado como expirado (A4). |
| A documentação do TMDB diz que sessões de convidado não usadas podem ser apagadas antes do `expires_at`. | Sem impacto hoje: nenhuma chamada usa o `guest_session_id`. Quando a avaliação for liberada (se for), tratar o 401 pela D31. |
| Relógio do aparelho errado adianta ou atrasa a expiração local. | Aceito: no pior caso o visitante gera outra sessão com um toque. |
| Sessão de conta salva mas inválida abre a Home como logado. | Coerente com a D5 sem validação; o 401 é tratado pela D31. |
| `FlutterSecureStorage` na Web guarda em `localStorage` criptografado. | Já é o caso do `session_id` de conta; nada novo. |
| `AuthImplementation.createGuestSession` cria o `Dio` internamente e não tem teste automatizado. | Coberto pela chamada real conferida em 2026-11-16 e pelos testes de `AuthApi` com `FakeAuthData`. |
| Mistura de idiomas ("Exit" × "Entrar"). | Fica para a i18n (D13). |

## 9. Estimativa de mudanças

- **Produção:** 5 arquivos novos (`access_mode`, 2 casos de uso, `guest_session_model`, `splash_page`) e 13 alterados (`storage_keys`, `auth_repository`, `auth_data`, `auth_implementation`, `auth_api`, `login_controller`, `profile_states`, `profile_cubit`, `locator`, `main`, `login_page`, `home_page`, `profile_page`).
- **Testes:** 5 arquivos novos (`auth_api_test`, `guest_session_model_test`, `splash_page_test`, além de `login_controller_test` e `profile_cubit_test`, já criados), 6 alterados (`fakes`, `test_locator`, `auth_usecases_test`, `login_page_test`, `home_page_test`, `profile_page_test`) e o teste de integração.
- **Documentação:** 2 documentos globais, READMEs das camadas e `specs/`.
