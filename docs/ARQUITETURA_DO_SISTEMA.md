# Arquitetura do Sistema — WikiCine (pacote `cinerating`)

> **Documento oficial de arquitetura.** Base para desenvolvimento no modelo *Spec-Driven Development*.
> Gerado a partir da análise do código em `lib/`, `test/`, `pubspec.yaml`, configurações de plataforma e Firebase.
> Data da análise: 2026-11-13 · commit de referência: `cd8a2ee`.
> **Atualização (2026-11-13):** refatoração para cumprir as regras R2–R9 (seção 3). Itens resolvidos estão marcados com ✅ **Resolvido**.
>
> **Convenção de leitura**
> - Afirmações sem marcação foram **verificadas no código** (com referência `arquivo:linha` quando relevante).
> - Trechos marcados com **Hipótese** são inferências não comprovadas pelo código.
> - Problemas são classificados como **[Violação]**, **[Débito]**, **[Bug]**, **[Risco]** ou **[Órfão]**.
>
> Documentos relacionados: [`OBJETIVO_DO_SISTEMA.md`](./OBJETIVO_DO_SISTEMA.md) · READMEs locais em cada pasta de `lib/` e `test/` (índice na seção 12).
>
> Este documento substitui o antigo `ARCHITECTURE.md` (removido por estar desatualizado).

---

## 1. Visão arquitetural

WikiCine é um **aplicativo Flutter de cliente único (sem back-end próprio)** que consome a **API REST v3 do TMDB** (`https://api.themoviedb.org/3`). Toda a lógica é executada no dispositivo; não há banco de dados local além do `flutter_secure_storage`, que guarda `tmdb_session_id` e `account_id`.

A organização segue uma **Clean Architecture em 3 camadas + núcleo transversal**:

```
lib/
├── main.dart              → ponto de entrada (setupLocator + MaterialApp → LoginPage)
├── core/                  → composição (DI), configuração de ambiente, tema, código legado
├── domain/                → entidades, contratos de repositório, casos de uso
├── data/                  → datasources HTTP (Dio), models/DTOs, implementações de repositório
└── presentation/          → páginas, widgets, cubits (flutter_bloc) e controllers (ChangeNotifier)
```

### 1.1 Diagrama de dependências entre camadas (estado real)

```
                  ┌──────────────────────── core/locator.dart (composition root) ─────────────────────────┐
                  │   importa e registra: data/*, domain/*, presentation/bloc/*, presentation/controllers/* │
                  │   injeta dependências pelo construtor de cubits, controllers, repositórios e datasources │
                  └──────────────────────────────────────────────────────────────────────────────────────────┘
                                   ▲ getIt<T>() só é chamado no locator e nas pages (para obter cubits/controllers)

 presentation ──► domain/usecases ──► domain/repositories (abstrações) ◄── data/repositories ──► data/datasources ──► TMDB (HTTP)
      │                                       ▲                                                         │
      └──► domain/entities ◄──────────────────┴──── data/models (estendem entidades / toEntity()) ◄─────┘
 data/*, presentation/pages/login_page.dart ──► core/shared (env.dart, storage_keys.dart, themes/)
```

### 1.2 Pilha tecnológica (fonte: `pubspec.yaml` / `pubspec.lock`)

| Dependência | Versão (lock) | Uso real no código |
|---|---|---|
| Flutter / Dart SDK | Dart `^3.11.5`; lock exige Flutter `>=3.47.0` | Framework. Usa *dot shorthands* (`.start`, `.spaceBetween`), recurso de Dart recente. |
| `material_ui` | 1.11.0 | Importado no lugar de `package:flutter/material.dart` em todos os widgets. **Hipótese:** pacote que reexporta a biblioteca Material do Flutter. |
| `dio` | ^5.9.2 | Cliente HTTP em todos os datasources e serviços legados. |
| `bloc` / `flutter_bloc` | ^9.2.1 / ^9.1.1 | `Cubit` + `BlocBuilder`. Não há `BlocProvider`: cubits são passados via `bloc:`. |
| `get_it` | ^8.0.0 | Service locator global `getIt` (`core/locator.dart:35`). |
| `flutter_secure_storage` | ^11.1.0 | Persistência de `tmdb_session_id` e `account_id`. |
| `cached_network_image` | ^3.4.1 | Apenas em `MovieCard`. Demais imagens usam `Image.network`. |
| `intl` | ^0.20.3 | `DateFormat("dd/MM/yyyy")` em `ContentDetail`. |
| `url_launcher` | ^6.3.2 | Abre `https://www.themoviedb.org/signup` na `LoginPage`. |
| `firebase_core` | ^4.15.0 | **Declarado, mas nunca importado nem inicializado** em `lib/`. |
| `cupertino_icons` | ^1.0.8 | Não referenciado no código Dart. |
| `flutter_lints` (dev) | ^6.0.0 | Regras padrão (`analysis_options.yaml`), sem customizações. |

---

## 2. Padrões utilizados

| Padrão | Onde | Observação |
|---|---|---|
| **Clean Architecture** (domain / data / presentation) | Estrutura de `lib/` | Aplicada parcialmente — ver seção 7. |
| **Repository** | `domain/repositories/*` (contratos) e `data/repositories/*` (impl.) | Implementações são *pass-through* para o datasource. Contratos 100% tipados. |
| **Datasource** (interface + implementação) | `data/datasources/data/*` (interfaces) e `data/datasources/implementations/*` | Toda fonte é remota (HTTP). |
| **Use Case** (classe com `call()`) | `domain/usecases/**` | Um caso de uso por operação; quase todos apenas delegam (`GetMovieCrewUseCase` filtra o elenco por "Acting"). |
| **DTO herdando entidade** | `MovieSimpleModel`, `MovieDetailModel` → `Movie`; `TvShowModel` → `TvShow`; `UserModel` → `User`; `GenreModel` → `Genre` | Models *são* entidades (herança). Créditos usam mapeamento explícito `toEntity()` (`CrewModel`, `Cast`, `TvShowCrew` → `CastMember`/`Credits`). |
| **Service Locator** (`get_it`) + injeção por construtor | `core/locator.dart` | O locator monta o grafo e injeta as dependências pelo construtor. As pages obtêm cubits/controllers via `getIt<T>()`. |
| **Cubit + estados por herança** | `presentation/bloc/**` | Estados como classes simples (sem `Equatable`). Uso de `part`/`part of` em home, movie_detail, serie_detail. |
| **ChangeNotifier controller** | `LoginController` | Estado de login/sessão consumido via `ListenableBuilder`. |
| **Enum de ambiente** | `core/shared/env.dart` | Valores injetados com `--dart-define` (`TOKEN`, `API_KEY`). |
| **Navegação imperativa** | `Navigator.push/pushReplacement` + `MaterialPageRoute` | Não há rotas nomeadas. |

---

## 3. Regras arquiteturais

As regras abaixo descrevem o **contrato desejado**. A coluna "Status" indica a aderência atual.

| # | Regra | Status atual |
|---|---|---|
| R1 | `domain/` não importa `data/`, `presentation/`, `core/` nem pacotes de infraestrutura (Dio, storage, Flutter). | ✅ Cumprida. |
| R2 | `presentation/` acessa dados **somente via casos de uso** do `domain/`. | ✅ **Resolvido.** `ProfileCubit` usa `GetUserFavoritesUseCase`. |
| R3 | `presentation/` não importa `data/`. | ✅ **Resolvido.** Cubits, estados e widgets usam apenas entidades (`Movie`, `TvShow`, `Credits`, `CastMember`, `Genre`). |
| R4 | Contratos de domínio retornam **entidades tipadas**, nunca `dynamic`/JSON cru. | ✅ **Resolvido.** `getMovieCredits`/`getTvShowCredits` retornam `Credits`; detalhes usam `getMovieDetails`/`getTvShowDetails` tipados. Métodos `...Full` e `getMovieCrew`/`getTvShowCrew` (dynamic) foram removidos. |
| R5 | Um datasource não depende de repositórios nem de outros datasources; composição é feita no locator. | ✅ **Resolvido.** `AuthImplementation` não busca mais favoritos; favoritos ficaram em `UserData`/`UserImplementation`. |
| R6 | Toda dependência é registrada em `core/locator.dart`. | ✅ **Resolvido.** `SerieCubit`, `UserData`, `UserRepository`, `GetUserFavoritesUseCase` e `FlutterSecureStorage` registrados. |
| R7 | Somente `core/shared/env.dart` conhece URLs, tokens e chaves. | ✅ **Resolvido.** URL de cadastro movida para `Environment.signupUrl`. |
| R8 | Segredos não são versionados. | ✅ **Resolvido no estado atual** (`.vscode/launch.json` removido do índice; continua local e ignorado). ⚠️ As credenciais **permanecem no histórico do Git** e devem ser revogadas/rotacionadas no TMDB. |
| R9 | Todo código em `lib/` é alcançável a partir de `main.dart`. | ✅ **Resolvido.** Removidos `core/services/`, `routes.dart`, `HomePeople`; `UserRepository` agora é implementado e usado; registro sem uso de `AppColors` removido. |

---

## 4. Convenções técnicas

### 4.1 Convenções observadas
- **Pacote Dart:** `cinerating` (imports absolutos `package:cinerating/...`). Nome de produto exibido: **"WikiCine"** (AppBar da Home). Nome nativo: `cinerating` (Android `android:label`, `web/index.html`) / `Cinerating` (iOS `CFBundleDisplayName`). Repositório antigo: `CineRating`.
- **Arquivos:** `snake_case.dart`. Casos de uso: `<verbo>_<objeto>_usecase.dart`.
- **Classes de caso de uso:** `XxxUseCase` com método `call(...)`.
- **Datasources:** interface `XxxData` em `datasources/data/`, implementação `XxxImplementation` em `datasources/implementations/`.
- **Models:** `XxxModel` com `fromMap`, `toMap`, `fromJson(String)`, `toJson()`, `copyWith` (estilo gerado por *quicktype*; **Hipótese** sobre a origem).
- **Chaves de storage:** centralizadas em `core/shared/storage_keys.dart` (`StorageKeys.sessionId`, `StorageKeys.accountId`).
- **URLs de imagem:** os models concatenam `Environment.production.mediaUrl` (`.../t/p/w400`) ao `*_path` no `fromMap`. Exceções: `BelongsToCollection`, `ProductionCompany`, `CreatedBy`, `Season`, `Network`, `LastEpisodeToAir` mantêm o path cru.
- **Estados de Cubit:** `XxxInitial`, `XxxLoading`, `XxxSuccess`/dados, `XxxError`.
- **Mensagens de UI:** mistura de português ("Pesquisar", "Preencha todos os campos") e inglês ("Profile", "Settings", "Exit", "Genres:", "Cast:").
- **Imports:** mistura de relativos (`../../`) e absolutos (`package:cinerating/`).

### 4.2 Inconsistências de nomenclatura **[Débito]**
| Item | Inconsistência |
|---|---|
| Repositórios | `AuthApi`, `MovieApi` vs `TvRepositoryImpl` (arquivo `tv_api.dart`). |
| Séries | `tv_show` (domain/usecases, pages) vs `serie_detail`/`SerieCubit`/`SerieState` (bloc). |
| Estados | `home_states.dart`/`movie_states.dart`/`profile_states.dart` (plural) vs `serie_state.dart` (singular). |
| Pasta de interfaces | `datasources/data/` (nome ambíguo com a camada `data/`). |
| Classes duplicadas | `ProductionCountry` existe em `movie_detail_model.dart` **e** em `tv_show_model.dart` (conflito se ambos forem importados no mesmo arquivo). `Genre` foi unificado em `genre_model.dart` (`GenreModel`). |

---

## 5. Separação de responsabilidades

| Camada / módulo | Responsabilidade | README local |
|---|---|---|
| `lib/main.dart` | Inicializa o locator e monta `MaterialApp` com `LoginPage` como home. | [`lib/README.md`](../lib/README.md) |
| `core/locator.dart` | *Composition root*: registra e injeta datasources, repositórios, casos de uso, controllers e cubits. | [`lib/core/README.md`](../lib/core/README.md) |
| `core/shared/` | Ambiente (`Environment`), chaves de storage (`StorageKeys`), cores (`AppColors`). | [`lib/core/shared/README.md`](../lib/core/shared/README.md) |
| `domain/entities/` | `Movie`, `TvShow`, `User`, `Avatar`, `Genre`, `Credits`, `CastMember`. | [`lib/domain/entities/README.md`](../lib/domain/entities/README.md) |
| `domain/repositories/` | Contratos `AuthRepository`, `MovieRepository`, `TvRepository`, `UserRepository`. | [`lib/domain/repositories/README.md`](../lib/domain/repositories/README.md) |
| `domain/usecases/` | 12 casos de uso (auth, movies, tv_show, user). | [`lib/domain/usecases/README.md`](../lib/domain/usecases/README.md) |
| `data/datasources/` | Chamadas HTTP ao TMDB e acesso ao secure storage. | [`lib/data/datasources/README.md`](../lib/data/datasources/README.md) |
| `data/models/` | DTOs com (de)serialização JSON. | [`lib/data/models/README.md`](../lib/data/models/README.md) |
| `data/repositories/` | Implementações dos contratos de domínio (`AuthApi`, `MovieApi`, `TvRepositoryImpl`, `UserApi`). | [`lib/data/repositories/README.md`](../lib/data/repositories/README.md) |
| `presentation/bloc/` | Estado das telas Home, Detalhe de filme, Detalhe de série, Perfil. | [`lib/presentation/bloc/README.md`](../lib/presentation/bloc/README.md) |
| `presentation/controllers/` | `LoginController` (sessão) e `HomeController` (busca). | [`lib/presentation/controllers/README.md`](../lib/presentation/controllers/README.md) |
| `presentation/pages/` | 5 telas: Login, Home (+Drawer), Detalhe de filme, Detalhe de série, Perfil. | [`lib/presentation/pages/README.md`](../lib/presentation/pages/README.md) |
| `presentation/widgets/` | Componentes visuais reutilizáveis. | [`lib/presentation/widgets/README.md`](../lib/presentation/widgets/README.md) |
| `test/`, `integration_test/` | Testes unitários (casos de uso), de widget (páginas e widgets de conteúdo) e de integração (fluxo completo com repositórios falsos). | [`test/README.md`](../test/README.md) |

---

## 6. Fluxo de comunicação entre módulos

### 6.1 Inicialização
```
main() → setupLocator() → runApp(MyApp) → MaterialApp(home: LoginPage)
```
Não há `WidgetsFlutterBinding.ensureInitialized()` nem `Firebase.initializeApp()`.

### 6.2 Login (TMDB "validate_with_login")
```
LoginPage._handleLogin
  └─ LoginController.login()                          (LazySingleton, ChangeNotifier)
       └─ LoginUseCase(username, password)
            └─ AuthRepository → AuthApi.login
                 └─ AuthData → AuthImplementation.login
                      1. GET  /authentication/token/new                 (?api_key)
                      2. POST /authentication/token/validate_with_login (?api_key, body: username/password/request_token)
                      3. POST /authentication/session/new               (?api_key, body: request_token)
                      4. secure_storage.write(StorageKeys.sessionId)
                      5. getAccountDetails(sessionId):
                           GET /account?session_id=…
                           secure_storage.write(StorageKeys.accountId)
                      → User (UserModel)
  └─ sucesso → Navigator.pushReplacement(HomePage)
```
Todas as requisições também enviam `Authorization: Bearer <TOKEN>` (token de aplicação, não do usuário).

### 6.3 Sessão existente
- `LoginPage.initState` e `DrawerWidget.initState` chamam `LoginController.checkExistingSession()` → `GetCurrentUserUseCase` → `AuthApi.getCurrentUser` (lê a sessão; se existir, refaz `getAccountDetails`).
- **Observação:** a `LoginPage` **não redireciona** para a Home quando há sessão; apenas popula `currentUser`.

### 6.4 Home (listagem e busca)
```
HomePage.initState → HomeCubit.getMovies() → GetMoviesUseCase → MovieRepository → MovieImplementation  GET /discover/movie
SessionCard "TV"   → HomeCubit.getTvShows() → GetTvShowsUseCase → TvRepository → TvImplementation       GET /discover/tv
TextField onEditingComplete → HomeController.setList(text, homeCubit)
     estado HomeMovie → getMovie(text)  → SearchMoviesUseCase   GET /search/movie?query&language=en-US;pt-BR
     estado HomeTv    → getTvShow(text) → SearchTvShowsUseCase  GET /search/tv?query&language=en-US;pt-BR
ContentList (grid) → tap → MovieDetailPage(movieId) | TvShowDetailPage(id)
```

### 6.5 Detalhe de filme
```
MovieDetailPage → getIt<MovieCubit>() → getMovieDetails(id)
   GetMovieDetailsUseCase → MovieRepository.getMovieDetails → GET /movie/{id}          → Movie (MovieDetailModel)
   GetMovieCrewUseCase    → MovieRepository.getMovieCredits → GET /movie/{id}/credits  → Credits
        data: cast = credits.cast; director = 1º membro de credits.crew com job == "Director"
        domínio: cast filtrado por department == "Acting"
   GetUserFavoritesUseCase → UserRepository → GET /account/{account_id}/favorite/movies → isFavorite (false em erro)
   emit MovieSuccess(movie, cast, director?, isFavorite) → ContentDetail(type: "movie")
```

### 6.6 Detalhe de série
```
TvShowDetailPage → getIt<SerieCubit>() → getSerieDetail(id)
   GetTvShowDetailsUseCase → TvRepository.getTvShowDetails → GET /tv/{id}                    → TvShow (TvShowModel)
   GetTvShowCrewUseCase    → TvRepository.getTvShowCredits → GET /tv/{id}/aggregate_credits  → Credits (personagem = roles[0])
   emit SerieSuccess(tvShow, cast) → ContentDetail(type: "tv")
```

### 6.7 Perfil
```
Drawer "Profile" → ProfilePage → ProfileCubit.initProfile()
   GetUserFavoritesUseCase → UserRepository → UserImplementation → GET /account/{account_id}/favorite/movies
   emit ProfileSuccess(favorites, watchlist: [])  → lista horizontal → tap → MovieDetailPage
   Cabeçalho usa LoginController.currentUser (singleton).
```

### 6.8 Logout
`DrawerWidget._handleLogout` → `LoginController.logout()` → `LogoutUseCase` → `AuthApi.logout` (apaga `StorageKeys.sessionId` e `StorageKeys.accountId`) → `pushReplacement(LoginPage)`.

### 6.9 Ciclo de vida no locator (`core/locator.dart`)
| Tipo | Registro |
|---|---|
| `FlutterSecureStorage` | `registerLazySingleton` (compartilhado por `AuthImplementation`, `UserImplementation`, `AuthApi`) |
| `AuthData`, `MovieData`, `TvData`, `UserData` | `registerLazySingleton` |
| `AuthRepository`, `MovieRepository`, `TvRepository`, `UserRepository` | `registerLazySingleton` |
| 12 casos de uso | `registerFactory` |
| `LoginController` | `registerLazySingleton` (casos de uso injetados no construtor) |
| `HomeController` | `registerFactory` |
| `HomeCubit`, `MovieCubit`, `SerieCubit`, `ProfileCubit` | `registerFactory` (casos de uso injetados no construtor) |

---

## 7. Riscos técnicos, acoplamentos e violações

### 7.1 Bugs identificados no código
| ID | Descrição | Evidência |
|---|---|---|
| B1 | ✅ **Resolvido.** O diretor do filme não era exibido porque só o `cast` era lido. Agora `MovieImplementation.getMovieCredits` busca o diretor em `crew`. | `movie_implementation.dart` |
| B2 | **Menu "Settings" do Drawer não tem efeito visível.** Faz `getIt<HomeCubit>()`, mas `HomeCubit` é `registerFactory`: cria uma nova instância, diferente da usada pela `HomePage`. | `home_page.dart:255-259`; `locator.dart:110` |
| B3 | **Exceção ao renderizar filme sem data** (confirmado por teste, hoje marcado como `skip` em `content_detail_test.dart`). `DateFormat.format` recebe `content.releaseDate` (pode ser `null`) quando `type == "movie"`; o `?? DateTime.now()` só se aplica ao ramo de série. | `content_detail.dart:175-178`; `movie_detail_model.dart:152` |
| B4 | **Busca ignorada fora dos estados de dados.** `HomeController.setList` não faz nada se o estado for `HomeLoading`, `HomeError` ou `HomeInitial`. | `home_controller.dart:7-23` |
| B5 | **Logout incompleto.** Agora remove `account_id`, mas ainda não invalida a sessão no TMDB (`DELETE /authentication/session`). | `auth_api.dart` |
| B6 | **Favoritar é no-op.** O ícone de coração tem `onTap: () {}`. | `content_detail.dart:136` |
| B7 | `Image.network("")` sem `errorBuilder` quando o usuário não tem avatar (Drawer e Perfil). **Hipótese:** gera erro de carregamento de imagem em tempo de execução. | `home_page.dart:213`; `profile_page.dart:87` |
| B8 | ✅ **Resolvido (achado pelos testes).** A aba TV quebrava: `ContentList` lia `show.title` e `TvShow` não tem esse getter (`NoSuchMethodError`). Agora usa `title` para filmes e `name` para séries. | `content_list.dart` |
| B9 | ✅ **Resolvido (achado pelos testes).** `ListTile`s do Drawer dentro de `Container` com cor de fundo disparavam assertion em modo debug; o fundo passou a ser um `Material`. | `home_page.dart` (`DrawerWidget`) |
| B10 | ✅ **Resolvido (achado pelos testes).** Logout pelo Drawer disparava "setState() called during build": `LoginPage.initState` chamava `checkExistingSession()` (que notifica o `DrawerWidget` ainda montado) de forma síncrona. Agora é adiado com `Future.microtask`. | `login_page.dart` |

### 7.2 Violações arquiteturais e acoplamentos
| ID | Descrição |
|---|---|
| V1 | ✅ **Resolvido.** `AuthImplementation` não depende mais de `MovieApi`/`MovieImplementation`; favoritos ficam em `UserImplementation`. |
| V2 | ✅ **Resolvido.** Contratos tipados (`Credits`, `Movie`, `TvShow`); parsing feito em `data/`. |
| V3 | ✅ **Resolvido.** A apresentação não importa `data/`. |
| V4 | ✅ **Resolvido** em cubits e controllers (injeção por construtor). As pages ainda chamam `getIt<T>()` para obter cubits/controllers — uso aceito pela diretriz 4. |
| V5 | ✅ **Resolvido.** `ProfileCubit` usa `GetUserFavoritesUseCase`. |
| V6 | **`core/locator.dart` importa `presentation/`**: o "núcleo" depende de todas as camadas. Aceitável para *composition root*, mas o arquivo vive em `core/`, que também é importado por `data/` e `presentation/`. |
| V7 | **Widgets importam páginas** (`ContentList` → `MovieDetailPage`/`TvShowDetailPage`): navegação embutida em componente reutilizável. |
| V8 | **`ContentDetail.content` é `dynamic`** (filme ou série), com distinção pela string `type == "movie" / "tv"`. Elenco e diretor já são tipados (`CastMember`). |
| V9 | ✅ **Resolvido.** `User` não tem mais `favoriteMovies`; todos os campos são `final`. |
| V10 | **Parcialmente resolvido.** Abrir um filme não chama mais `GET /account`; ainda faz `GET favorites` para calcular `isFavorite`. |

### 7.3 Módulos e símbolos órfãos
| Item | Situação |
|---|---|
| `core/services/*`, `core/shared/routes.dart`, `HomePeople`, `GetUserFavoritesUsecases` | ✅ **Removidos** (ou substituídos por `GetUserFavoritesUseCase`, em uso). |
| `UserRepository` | ✅ Implementado por `UserApi` e usado. |
| Registro de `AppColors` no locator e variáveis `appColors` | ✅ Removidos (a classe continua com campos `static`). |
| `firebase_core`, `firebase.json`, `.firebaserc`, `public/`, `android/app/google-services.json` | Configuração Firebase sem uso em `lib/` (fora de `lib/`, não coberto pela R9). |
| `.agents/skills/*`, `skills-lock.json` | Skills de agentes de IA para Firebase; não fazem parte do app. |
| `test/home_test.dart`, `test/login_test.dart` | ✅ Removidos (eram vazios); substituídos pela suíte em `test/` e `integration_test/`. |

### 7.4 Riscos operacionais e de segurança
| ID | Risco |
|---|---|
| S1 | **Credenciais no histórico do Git:** `.vscode/launch.json` (com `API_KEY` e `TOKEN`) foi removido do índice, mas continua nos commits anteriores. É preciso revogar/rotacionar as credenciais no TMDB. |
| S2 | **Token de aplicação embutido no binário** via `String.fromEnvironment` — extraível de builds distribuídos. Inerente a apps cliente-only. |
| S3 | **Senha do TMDB trafega pelo app** (fluxo `validate_with_login`) em vez do fluxo de aprovação via navegador. |
| S4 | **Build de release assinado com chave de debug** (`android/app/build.gradle.kts`, `signingConfig = debug`). |
| S5 | `pubspec.yaml` declara o asset `assets/svg/`, mas a pasta não existe no repositório. Confirmado: `flutter analyze` emite o aviso `asset_directory_does_not_exist`. **Hipótese:** `flutter build` também falha ou avisa em um clone limpo. |
| S6 | `material_ui: any` — versão não restrita no `pubspec.yaml`. |
| S7 | **Sem tratamento de erro tipado:** exceções são engolidas e convertidas em mensagens genéricas; não há retry, logs nem distinção offline/401/404. |
| S8 | **Sem paginação**: apenas a primeira página de `discover`/`search` é carregada. |
| S9 | **Recursos não liberados:** cubits nunca recebem `close()`; `TextEditingController`s (em `LoginController` singleton e `HomeController`) nunca recebem `dispose()`. |
| S10 | `language: 'en-US;pt-BR'` não segue o formato de idioma único do TMDB. **Hipótese:** a API ignora o valor e usa o padrão `en-US`. |
| S11 | Endpoint `/account/{id}/favorite/movies` é chamado **sem** `session_id`. **Hipótese:** funciona apenas porque o `TOKEN` Bearer é do mesmo usuário dono da conta; para outros usuários pode retornar 401 ou dados de outra conta. |
| S12 | **Parcialmente resolvido.** Há testes de casos de uso, de widget e de integração; faltam testes de `data/` (models, datasources, repositórios), dos cubits/controllers isolados e CI. |

### 7.5 Dependências críticas
1. **TMDB API v3** — única fonte de dados. Mudanças de contrato quebram models (parsing manual sem validação).
2. **`TOKEN` e `API_KEY` via `--dart-define`** — sem eles, todas as chamadas falham (strings vazias). `TOKEN` é usado no header `Authorization`; `API_KEY` só nos endpoints de autenticação.
3. **`flutter_secure_storage`** — guarda a sessão; chaves centralizadas em `core/shared/storage_keys.dart` e instância única registrada no locator.
4. **`get_it`** — monta todo o grafo; erro de registro só aparece em tempo de execução.
5. **`material_ui`** — substitui o import Material em todos os widgets; troca/remoção afeta toda a camada de apresentação.

---

## 8. Infraestrutura e plataformas

| Pasta / arquivo | Conteúdo |
|---|---|
| `android/` | App Android, `namespace`/`applicationId` = `br.com.fourinnovation.scanning.cinerating`, Java/Kotlin 17, plugin `com.google.gms.google-services`, permissões `INTERNET` e `ACCESS_NETWORK_STATE`. `android/build/reports/problems/problems-report.html` está versionado (artefato de build). |
| `ios/` | Runner padrão Flutter (`AppDelegate.swift`, `SceneDelegate.swift`), `CFBundleDisplayName = Cinerating`. |
| `web/` | Shell padrão Flutter Web (`title = cinerating`). Não há evidência de deploy web. |
| `public/` + `firebase.json` + `.firebaserc` | Firebase Hosting (projeto `cinerating633`) com página padrão "Welcome to Firebase Hosting". `firebase.json` referencia `lib/firebase_options.dart`, que não existe (e está no `.gitignore`). |
| `assets/img/` | `logo.png` (usado na `LoginPage`) e `logo_mini.png` (não referenciado no código). |
| `.vscode/launch.json` | Configurações de execução (ver S1). |
| CI/CD | Não há workflows (`.github/` inexistente). Distribuição do APK é feita manualmente (link do Google Drive no `README.md`). |

---

## 9. Débitos técnicos priorizados

| Prioridade | Ação | Resolve |
|---|---|---|
| P0 | Revogar/rotacionar as credenciais TMDB que estão no histórico do Git. | S1 |
| P1 | Corrigir `DateFormat` com data nula e `Image.network("")`. | B3, B7 |
| P1 | Corrigir "Settings" do Drawer (instância de `HomeCubit` desconectada). | B2 |
| P2 | Usar `BlocProvider`/`close()` para ciclo de vida dos cubits; `dispose()` nos controllers de texto. | S9 |
| P2 | Completar testes: `data/models` (`fromMap`), datasources/repositórios, cubits e controllers; rodar `flutter test` em CI. | S12 |
| P2 | Tipar `ContentDetail.content` e retirar a navegação de `ContentList`. | V7, V8 |
| P3 | Padronizar nomes (seção 4.2), idioma da UI e nome do produto. | 4.2 |
| P3 | Decidir sobre Firebase: integrar (`Firebase.initializeApp`) ou remover dependência/configuração. | 7.3 |

---

## 10. Diretrizes para futuras implementações

1. **Especifique antes de codificar (SDD).** Toda feature nova deve ter uma especificação com: caso de uso, entidade(s), contrato de repositório, endpoints TMDB, estados de UI e critérios de aceite. Atualize este documento e o README do módulo afetado no mesmo PR.
2. **Ordem de criação de uma feature:**
   1. `domain/entities/` — entidade imutável (`final`), sem dependência de Flutter/Dio.
   2. `domain/repositories/` — contrato **tipado** (proibido `dynamic`).
   3. `domain/usecases/<contexto>/` — `XxxUseCase` com `call()`.
   4. `data/models/` — DTO com `fromMap` e conversão para entidade.
   5. `data/datasources/data/` (interface) + `data/datasources/implementations/` (Dio).
   6. `data/repositories/` — implementação do contrato.
   7. `presentation/bloc/<feature>/` — Cubit + estados.
   8. `presentation/pages/` e `presentation/widgets/`.
   9. `core/locator.dart` — registro de **todas** as novas classes.
   10. `test/` — testes por camada.
3. **Dependências permitidas:** `presentation → domain`; `data → domain`; `data → core/shared`; `presentation → core/shared`; `core/locator → *`. Qualquer outra direção é violação.
4. **Injeção por construtor.** `getIt` aparece apenas no locator e nas pages (para obter cubits/controllers). Nunca em cubits, controllers, casos de uso, repositórios ou datasources.
5. **Acesso HTTP só em `data/datasources/implementations/`.**
6. **Segredos** apenas via `--dart-define` local, nunca em arquivos versionados.
7. **Chaves de storage** devem ser declaradas em `core/shared/storage_keys.dart`.
8. **Novos estados de Cubit** devem cobrir explicitamente `Initial`, `Loading`, `Success`, `Error` e ser tratados na page.
9. **Navegação:** se rotas nomeadas forem adotadas, migrar todas as navegações; não misturar abordagens.
10. **Consistência documental:** qualquer alteração em pastas de `lib/` exige atualização do README local correspondente e, se impactar fluxo ou regra, deste documento.

---

## 11. Glossário
| Termo | Significado |
|---|---|
| TMDB | The Movie Database — API pública de filmes/séries. |
| Request token | Token temporário do TMDB usado para autenticar o usuário. |
| Session ID | Identificador de sessão do usuário TMDB, salvo em `tmdb_session_id`. |
| `TOKEN` | *API Read Access Token* (Bearer) do TMDB, injetado via `--dart-define`. |
| `API_KEY` | Chave v3 do TMDB, usada como query param nos endpoints de autenticação. |
| Composition root | Local único onde o grafo de dependências é montado (`core/locator.dart`). |

## 12. Índice de documentação local
- [`lib/README.md`](../lib/README.md)
- [`lib/core/README.md`](../lib/core/README.md) · [`lib/core/shared/README.md`](../lib/core/shared/README.md)
- [`lib/domain/README.md`](../lib/domain/README.md) · [`entities`](../lib/domain/entities/README.md) · [`repositories`](../lib/domain/repositories/README.md) · [`usecases`](../lib/domain/usecases/README.md)
- [`lib/data/README.md`](../lib/data/README.md) · [`datasources`](../lib/data/datasources/README.md) · [`models`](../lib/data/models/README.md) · [`repositories`](../lib/data/repositories/README.md)
- [`lib/presentation/README.md`](../lib/presentation/README.md) · [`bloc`](../lib/presentation/bloc/README.md) · [`controllers`](../lib/presentation/controllers/README.md) · [`pages`](../lib/presentation/pages/README.md) · [`widgets`](../lib/presentation/widgets/README.md)
- [`test/README.md`](../test/README.md)
