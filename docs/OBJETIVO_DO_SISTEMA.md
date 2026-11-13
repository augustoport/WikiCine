# Objetivo do Sistema — WikiCine

> Documento oficial de produto/negócio, derivado do código-fonte e do `README.md` raiz.
> Data da análise: 2026-11-13 · commit de referência: `cd8a2ee` (atualizado após a refatoração de conformidade arquitetural).
> Decisões de produto confirmadas pelo mantenedor em entrevistas (2026-11-13, rodadas 1 e 2) estão na seção 8 e prevalecem sobre qualquer **Hipótese**.
> Inferências estão marcadas como **Hipótese**. Para detalhes técnicos, ver [`ARQUITETURA_DO_SISTEMA.md`](./ARQUITETURA_DO_SISTEMA.md).

---

## 1. Propósito principal

WikiCine é um **aplicativo móvel (Flutter) de consulta a filmes e séries** que usa o **The Movie Database (TMDB)** como fonte de dados. Ele permite que um usuário com conta no TMDB faça login, navegue por catálogos de filmes e séries, pesquise títulos, veja detalhes (sinopse, nota, gêneros, data, duração, elenco) e consulte seus **filmes favoritos** no perfil.

É um **projeto de portfólio** (confirmado pelo mantenedor) que demonstra Flutter, Clean Architecture, BLoC/Cubit e integração com API REST. O foco é qualidade técnica e boas práticas, não a operação com usuários reais. O nome oficial do produto é **WikiCine**.

## 2. Problemas que o sistema resolve

| Problema | Como o sistema atende (verificado no código) |
|---|---|
| Descobrir filmes e séries | Lista de `discover/movie` e `discover/tv` na Home. |
| Encontrar um título específico | Busca por nome (`search/movie`, `search/tv`). |
| Saber detalhes de um título antes de assistir | Tela de detalhe com pôster, backdrop, nota média, nº de votos, data, duração (filmes), gêneros, sinopse e elenco. |
| Acessar dados pessoais do TMDB no celular | Login com credenciais TMDB e lista de filmes favoritos no Perfil; indicação de "favorito" no detalhe do filme. |

**Decisão (D3):** o usuário logado deverá poder **avaliar** filmes e séries na sua conta TMDB. Hoje o app exibe apenas a **nota média** do TMDB, sem envio de nota.

## 3. Atores envolvidos

| Ator | Papel |
|---|---|
| **Usuário final (com conta TMDB)** | Faz login, navega, pesquisa, vê detalhes e favoritos. Login é obrigatório para entrar na Home. |
| **Visitante sem conta TMDB** | Hoje só pode usar o link "Clique aqui" da tela de login, que abre `https://www.themoviedb.org/signup` no navegador. Um modo **guest** está decidido, mas suas regras ainda serão discutidas (P1). |
| **TMDB (sistema externo)** | Fornece catálogo, autenticação, dados da conta e favoritos. |
| **Desenvolvedor/mantenedor** | Fornece `TOKEN` e `API_KEY` do TMDB via `--dart-define` no build. O `TOKEN` é o token de leitura da **conta TMDB pessoal do mantenedor**. |
| **Firebase (sistema externo)** | Configurado (projeto `cinerating633`), mas **sem uso funcional** no código atual. Decisão (D15): será usado para o **Hosting da versão Web**. |

## 4. Principais fluxos de negócio

### F1 — Autenticação
1. Usuário informa usuário e senha do TMDB.
2. Campos vazios → mensagem "Preencha todos os campos".
3. App cria *request token*, valida com login/senha, cria sessão e salva o `session_id` de forma segura.
4. App carrega os dados da conta (nome, username, avatar).
5. Sucesso → Home. Falha → "Usuário/Senha incorreto(s)".

### F2 — Navegação de catálogo
1. Home abre na aba **Movie** com filmes de `discover`.
2. Barra inferior alterna entre **Movie** e **TV**.
3. "Puxar para atualizar" recarrega a lista atual.

### F3 — Pesquisa
1. Usuário digita no campo "Pesquisar" e confirma.
2. Pesquisa na categoria ativa (filmes ou séries). Texto vazio recarrega o catálogo.

### F4 — Detalhe de título
1. Toque em um card abre o detalhe.
2. **Filme:** título, nota, votos, data de lançamento, duração, gêneros, sinopse, elenco (apenas atores), diretor e indicador de favorito.
3. **Série:** nome, nota, votos, data de estreia, gêneros, sinopse e elenco (com personagem). Duração exibida como "- min".

### F5 — Perfil e favoritos
1. Menu lateral → **Profile**.
2. Mostra avatar, nome e username, e a lista horizontal de **filmes favoritos** do TMDB.
3. Toque em um favorito abre o detalhe do filme.

### F6 — Sessão e saída
1. Ao abrir o app, se houver sessão salva, os dados do usuário são recarregados (mas a tela de login continua sendo exibida). **Decisão (D5):** com sessão válida, o app deve ir direto para a Home.
2. Menu lateral → **Exit** apaga a sessão local (sessão e conta) e volta ao login. **Decisão (D8):** deve também encerrar a sessão no TMDB.

## 5. Funcionalidades centrais (estado atual)

| Funcionalidade | Status |
|---|---|
| Login TMDB por usuário/senha | ✅ Implementada |
| Link para cadastro no TMDB | ✅ Implementada |
| Lista de filmes populares/descoberta | ✅ Implementada (apenas 1ª página) |
| Lista de séries | ✅ Implementada (apenas 1ª página) |
| Busca de filmes e séries | ✅ Implementada |
| Detalhe de filme com elenco e diretor | ✅ Implementada |
| Detalhe de série com elenco | ✅ Implementada |
| Perfil com favoritos | ✅ Implementada (somente filmes) |
| Indicador de favorito no detalhe do filme | ✅ Implementada (somente leitura) |
| Marcar/desmarcar favorito | ❌ Ícone presente, ação vazia |
| Watchlist | ❌ Estado prevê `watchlist`, sempre vazia |
| Configurações ("Settings") | ❌ Item de menu sem tela; ação atual sem efeito visível |
| Login automático com sessão salva | ❌ Sessão é carregada, mas não há redirecionamento |
| Avaliar títulos | ❌ Não implementado |
| Recursos Firebase | ❌ Apenas configuração |

## 6. Visão de produto

- **Posicionamento:** "companion app" de filmes e séries integrado à conta pessoal TMDB (`README.md`).
- **Natureza:** projeto de portfólio (D2).
- **Público:** usuários que já usam o TMDB. Interface multi-idioma, pelo menos pt-BR e inglês (D13).
- **Direção do produto (decidida, seção 8):** favoritos e watchlist editáveis para filmes e séries, avaliação de títulos pelo usuário, tela de configurações, rolagem infinita, créditos de séries com criadores, login automático, modo guest e versão Web publicada no Firebase Hosting.

## 7. Contexto operacional

| Aspecto | Situação |
|---|---|
| Plataformas | **Oficiais: Android, iOS e Web** (D4). Hoje só o Android tem distribuição (APK via Google Drive); a Web será publicada no Firebase Hosting (D15). |
| Back-end | Nenhum próprio. Comunicação direta app → `api.themoviedb.org/3`; imagens de `media.themoviedb.org/t/p/w400`. |
| Conectividade | Obrigatória. Não há cache de dados nem modo offline (apenas cache de imagens nos cards da Home). |
| Configuração de build | `flutter run --dart-define=TOKEN=<token> --dart-define=API_KEY=<chave>`. Sem esses valores, nenhuma chamada funciona. |
| Persistência local | `flutter_secure_storage`: `tmdb_session_id`, `account_id` (chaves em `core/shared/storage_keys.dart`). |
| Ambientes | Um único (`Environment.production`). |
| Idioma | Hoje: interface mista português/inglês; dados do TMDB em inglês por padrão (**Hipótese**, ver S10 na arquitetura). Decisão: interface multi-idioma (D13) e dados do TMDB no idioma da interface (D14). |
| Observabilidade | Nenhuma (sem logs, crash reporting ou analytics ativos). |
| Testes / CI | Testes unitários (casos de uso), de widget e de integração (`flutter test`, `flutter test integration_test`). Sem CI. |
| Limites externos | Sujeito às regras de uso e limites de requisição do TMDB (**Hipótese** quanto aos valores exatos). |

## 8. Decisões de produto (entrevista com o mantenedor, 2026-11-13)

Estas decisões são a **referência oficial** para as próximas especificações. Os códigos `Dn` são usados em outros documentos.

| ID | Tema | Decisão | Situação no código |
|---|---|---|---|
| D1 | Nome do produto | **WikiCine** em todos os lugares visíveis ao usuário (título do app, rótulos Android/iOS/Web, documentação). | Pendente: `MaterialApp.title = 'Flutter Demo'`, Android/Web `cinerating`, iOS `Cinerating`. |
| D2 | Natureza do projeto | **Portfólio**: prioridade em qualidade técnica e boas práticas. | — |
| D3 | Avaliações | O **usuário logado avalia** filmes e séries na conta TMDB (envio de nota). | Não implementado. |
| D4 | Plataformas | **Android, iOS e Web** são oficiais. | Só Android distribuído. |
| D5 | Sessão salva | Com sessão válida, **ir direto para a Home** ao abrir o app. | Não implementado (Login sempre aparece). |
| D6 | Fluxo de login | Manter **usuário e senha** dentro do app (`validate_with_login`). | Implementado. |
| D7 | Acesso | **Login obrigatório**, mais um **modo guest** (acesso sem login) cujas regras serão definidas depois. | Login obrigatório implementado; guest não. |
| D8 | Logout | Encerrar a sessão **também no TMDB** (`DELETE /authentication/session`). | Não implementado (só apaga local). |
| D9 | Favoritar | O coração no detalhe **marca/desmarca** o favorito na conta TMDB. | Ícone presente, ação vazia. |
| D10 | Favoritos de séries | **Filmes e séries** podem ser favoritos (Perfil e detalhe). | Só filmes, somente leitura. |
| D11 | Watchlist | **Implementar completa**: exibir no Perfil e adicionar/remover no detalhe. | Campo `watchlist` sempre vazio. |
| D12 | Settings | Criar uma **tela de configurações**. Conteúdo inicial sugerido: idioma (ligado a D13). | Item de menu sem efeito. |
| D13 | Idioma da interface | **Multi-idioma** (i18n), no mínimo pt-BR e inglês. | Textos fixos, mistos. |
| D14 | Idioma dos dados | Pedir dados ao TMDB **no mesmo idioma da interface**. | Usa `en-US;pt-BR` só nas buscas. |
| D15 | Firebase | Usar o **Firebase Hosting para publicar a versão Web**. | `public/` tem só a página padrão; `firebase.json` aponta para `public`, não para o build Web. |
| D16 | Créditos de séries | Exibir os **criadores** (`created_by`) no lugar do diretor. | Não implementado (só elenco). |
| D17 | Paginação | **Rolagem infinita** na Home e na busca. | Só a 1ª página. |
| D18 | `TOKEN` | É o token de leitura da **conta TMDB pessoal do mantenedor**. | Ver impacto em I1. |
| D19 | Credenciais expostas | O mantenedor **vai revogar** as credenciais que estão no histórico do Git. | Pendente (ação externa). |

### 8.0 Segunda rodada (resolve P1–P4)

| ID | Tema | Decisão | Situação no código |
|---|---|---|---|
| D20 | Modo guest — escopo (P1) | Visitante tem **leitura completa**: Home, busca e detalhes. Não usa sessão guest do TMDB. | Não implementado. |
| D21 | Modo guest — ações | Para o visitante, favoritar, watchlist, avaliar e o item **Profile** ficam **ocultos**. O menu mostra **"Entrar"**, que leva à tela de login. | Não implementado. |
| D22 | Entrada no app | Sem sessão, abre a **tela de login** com o botão secundário **"Continuar sem login"**. A escolha de guest **não é lembrada** ao reabrir. | Não implementado. |
| D23 | Avaliação — escala (P3) | **5 estrelas com meia estrela** (0,5★ a 5★). O valor enviado ao TMDB é o **dobro** (0,5★ = 1, 5★ = 10). | Não implementado. |
| D24 | Avaliação — remoção e exibição (P3) | O usuário pode **remover** a nota. A nota dele aparece **no detalhe** ("Sua nota", ao lado da média TMDB), numa **lista "Avaliados" no Perfil** e como **selo nos cards** da Home/busca. | Não implementado. |
| D25 | Settings — conteúdo (P2) | **Idioma**, **tema** (claro/escuro/sistema) e **Sobre** (versão, crédito obrigatório ao TMDB, link do repositório). Conta/logout continuam no menu lateral. | Não implementado. |
| D26 | Preferências | Na 1ª abertura: idioma do aparelho (pt-BR se português, senão en-US) e tema do sistema. Escolhas salvas no dispositivo. | Não implementado. |
| D27 | Proxy do TMDB (P4) | Um **proxy em Cloud Functions (Firebase)** guarda `TOKEN` e `API_KEY`. **Android, iOS e Web** chamam o proxy; nenhum app carrega segredos. | Não implementado. |
| D28 | Login pelo proxy | Mantém usuário/senha (D6) em todas as plataformas. A senha passa pelo proxy por HTTPS e o **corpo das requisições nunca é registrado em log**. A Web exige login igual ao mobile (com guest disponível). | Não implementado. |
| D29 | Estado da conta | Após o login, baixar **uma vez** favoritos, watchlist e avaliados (filmes e séries) para um **cache em memória**, atualizado a cada ação do usuário. Cards e detalhe consultam esse cache. | Não implementado. |
| D30 | Navegação | Migrar para **`go_router`** (URLs como `/movie/123`, `/tv/456`, guard central de login/guest). | Não implementado. |
| D31 | Erros | **Falhas tipadas**: sem conexão, sessão expirada (401 → volta ao login), não encontrado e desconhecido; mensagem traduzida e botão "Tentar de novo". Sem Crashlytics. | Não implementado. |
| D32 | Home | Manter **discover** (uma lista por aba, por popularidade) com rolagem infinita (D17). Sem seções nem filtros. | Parcial (1ª página). |
| D33 | Entrega | **CI no GitHub Actions** (`flutter analyze` + `flutter test` em PRs) e **deploy Web automático** no Firebase Hosting ao fazer merge na `master`. Assinatura de release e lojas ficam **fora do escopo** por ora. | Não implementado. |

### 8.1 Impactos identificados a partir das decisões

| ID | Impacto |
|---|---|
| I1 | Como o `TOKEN` pertence à conta do mantenedor (D18) e a busca de favoritos (`GET /account/{id}/favorite/movies`) **não envia `session_id`**, a hipótese S11 da arquitetura se torna um **risco concreto**: para outros usuários, a chamada pode falhar ou retornar dados da conta do mantenedor. Todas as chamadas de conta (favoritos, watchlist, avaliação — D3, D9–D11) devem enviar o `session_id` do usuário logado. |
| I2 | D13 + D14 exigem que o idioma escolhido seja passado como `language` (formato `pt-BR`/`en-US`) em **todas** as chamadas de catálogo e detalhe, substituindo o valor atual `en-US;pt-BR`. |
| I3 | D5 depende de validar a sessão ao abrir o app (o fluxo `getCurrentUser` já existe) e de uma tela inicial de carregamento antes de decidir entre Login e Home. |
| I4 | D15 exige que o `firebase.json` publique o build Web (`build/web`) em vez da pasta `public/`, e que a versão Web lide com CORS e segredos embutidos no JavaScript (o `TOKEN` fica visível no navegador). |
| I5 | D27 exige o **plano Blaze** (pago por uso) do Firebase para Cloud Functions, e o app deixa de receber segredos via `--dart-define`: passa a receber só a URL do proxy. Resolve S2 e a parte de segredos de I4. O proxy precisa de lista de caminhos permitidos (só os endpoints usados pelo app), CORS restrito ao domínio do Hosting e limite de requisições, para não virar um repasse aberto do token. |
| I6 | D28: a Cloud Function não pode registrar corpo nem query de `/authentication/*`; os logs padrão do Cloud Functions devem ser revisados. |
| I7 | D29 substitui a chamada de favoritos ao abrir cada filme (V10). O cache precisa ser limpo no logout, carregar todas as páginas das listas no início (o TMDB devolve 20 itens por página) e ficar vazio para o visitante. |
| I8 | D24 (selo nos cards) depende de D29; sem o cache, seriam N chamadas por tela. |
| I9 | D30 + D5 + D22: o guard do `go_router` decide entre Splash → Login → Home (logado ou guest). D21 vira regra do guard (rota `/profile` bloqueada para guest). |
| I10 | D31: "sessão expirada" precisa limpar a sessão local (como no logout) antes de redirecionar. |
| I11 | D25: os termos de uso da API do TMDB exigem atribuição (logo e aviso "This product uses the TMDB API but is not endorsed or certified by TMDB"), que fica na seção Sobre. |

## 9. Pendências

P1–P4 foram resolvidas na segunda rodada (D20–D33). Não há pendências de produto em aberto.

| ID | Tema | Resolvida por |
|---|---|---|
| P1 | Modo guest | D20, D21, D22 |
| P2 | Tela de configurações | D25, D26 |
| P3 | Avaliações | D23, D24 |
| P4 | Versão Web | D27, D28 |
