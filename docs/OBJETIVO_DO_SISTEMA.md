# Objetivo do Sistema — WikiCine

> Documento oficial de produto/negócio, derivado do código-fonte e do `README.md` raiz.
> Data da análise: 2026-11-13 · commit de referência: `cd8a2ee` (atualizado após a refatoração de conformidade arquitetural).
> Inferências estão marcadas como **Hipótese**. Para detalhes técnicos, ver [`ARQUITETURA_DO_SISTEMA.md`](./ARQUITETURA_DO_SISTEMA.md).

---

## 1. Propósito principal

WikiCine é um **aplicativo móvel (Flutter) de consulta a filmes e séries** que usa o **The Movie Database (TMDB)** como fonte de dados. Ele permite que um usuário com conta no TMDB faça login, navegue por catálogos de filmes e séries, pesquise títulos, veja detalhes (sinopse, nota, gêneros, data, duração, elenco) e consulte seus **filmes favoritos** no perfil.

Segundo o `README.md` raiz, trata-se de um **projeto de portfólio** que demonstra Flutter, Clean Architecture, BLoC/Cubit e integração com API REST.

## 2. Problemas que o sistema resolve

| Problema | Como o sistema atende (verificado no código) |
|---|---|
| Descobrir filmes e séries | Lista de `discover/movie` e `discover/tv` na Home. |
| Encontrar um título específico | Busca por nome (`search/movie`, `search/tv`). |
| Saber detalhes de um título antes de assistir | Tela de detalhe com pôster, backdrop, nota média, nº de votos, data, duração (filmes), gêneros, sinopse e elenco. |
| Acessar dados pessoais do TMDB no celular | Login com credenciais TMDB e lista de filmes favoritos no Perfil; indicação de "favorito" no detalhe do filme. |

**Hipótese:** o nome antigo "CineRating" e o `README.md` ("consultar avaliações dos usuários") sugerem intenção de focar em avaliações; hoje o app exibe apenas a **nota média** do TMDB, sem avaliações individuais nem envio de nota.

## 3. Atores envolvidos

| Ator | Papel |
|---|---|
| **Usuário final (com conta TMDB)** | Faz login, navega, pesquisa, vê detalhes e favoritos. Login é obrigatório para entrar na Home. |
| **Visitante sem conta TMDB** | Só pode usar o link "Clique aqui" da tela de login, que abre `https://www.themoviedb.org/signup` no navegador. |
| **TMDB (sistema externo)** | Fornece catálogo, autenticação, dados da conta e favoritos. |
| **Desenvolvedor/mantenedor** | Fornece `TOKEN` e `API_KEY` do TMDB via `--dart-define` no build. |
| **Firebase (sistema externo)** | Configurado (projeto `cinerating633`), mas **sem uso funcional** no código atual. |

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
1. Ao abrir o app, se houver sessão salva, os dados do usuário são recarregados (mas a tela de login continua sendo exibida).
2. Menu lateral → **Exit** apaga a sessão local (sessão e conta) e volta ao login.

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
- **Público:** usuários que já usam o TMDB e querem consultar o catálogo e seus favoritos pelo celular. **Hipótese:** foco inicial em público brasileiro (mensagens em português, formato de data `dd/MM/yyyy`).
- **Direção sugerida pelo código (Hipótese):** a presença de `watchlist`, ícone de favorito, item "Settings" e dependência Firebase indica um roadmap com: gerenciamento de favoritos/watchlist, configurações e algum serviço Firebase (analytics, hosting ou autenticação).

## 7. Contexto operacional

| Aspecto | Situação |
|---|---|
| Plataformas | Android (principal; APK distribuído via Google Drive conforme `README.md`), iOS e Web com estrutura padrão Flutter. |
| Back-end | Nenhum próprio. Comunicação direta app → `api.themoviedb.org/3`; imagens de `media.themoviedb.org/t/p/w400`. |
| Conectividade | Obrigatória. Não há cache de dados nem modo offline (apenas cache de imagens nos cards da Home). |
| Configuração de build | `flutter run --dart-define=TOKEN=<token> --dart-define=API_KEY=<chave>`. Sem esses valores, nenhuma chamada funciona. |
| Persistência local | `flutter_secure_storage`: `tmdb_session_id`, `account_id` (chaves em `core/shared/storage_keys.dart`). |
| Ambientes | Um único (`Environment.production`). |
| Idioma | Interface mista português/inglês; dados do TMDB em inglês por padrão (**Hipótese**, ver S10 na arquitetura). |
| Observabilidade | Nenhuma (sem logs, crash reporting ou analytics ativos). |
| Testes / CI | Testes unitários (casos de uso), de widget e de integração (`flutter test`, `flutter test integration_test`). Sem CI. |
| Limites externos | Sujeito às regras de uso e limites de requisição do TMDB (**Hipótese** quanto aos valores exatos). |
