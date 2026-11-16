# Feature Specification: Modo visitante (guest)

**Feature Branch**: `001-modo-visitante`

**Created**: 2026-11-16

**Status**: Clarified

**Input**: User description: "Modo visitante (guest): permitir acessar o app sem login, conforme as decisões D20, D21 e D22."

## Clarifications

### Session 2026-11-16
- Q: Depois que o visitante toca em "Entrar" e faz login com sucesso, para onde ele vai? → A: Sempre para a Home.
- Q: Se um visitante acessar diretamente uma área restrita (ex.: link do Perfil na Web), o que acontece? → A: Vai para a Home, como visitante.
- Q: O que o cabeçalho do menu lateral mostra para o visitante? → A: Saudação genérica: ícone de pessoa padrão e "Olá, visitante".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explorar o catálogo sem conta (Priority: P1)

Uma pessoa sem conta no TMDB (ou que não quer entrar agora) abre o app, escolhe "Continuar sem login" na tela de login e navega pelo catálogo: vê as listas de filmes e séries, pesquisa títulos e abre os detalhes, exatamente como um usuário logado.

**Why this priority**: É o objetivo da feature (D20): hoje quem não tem conta não consegue ver nada além da tela de login. Sozinha, esta história já entrega valor e é demonstrável.

**Independent Test**: Abrir o app sem sessão salva, tocar em "Continuar sem login" e conferir que Home, busca e detalhes de filme e de série funcionam.

**Acceptance Scenarios**:

1. **Given** o app aberto sem sessão salva, **When** a tela inicial aparece, **Then** é exibida a tela de login com o botão principal "Login" e o botão secundário "Continuar sem login" (D22).
2. **Given** a tela de login, **When** o usuário toca em "Continuar sem login", **Then** a Home é aberta com a lista de filmes, sem pedir usuário nem senha.
3. **Given** o visitante na Home, **When** ele alterna para séries, pesquisa um título ou abre um card, **Then** o resultado é o mesmo que um usuário logado veria (listas, busca e detalhes completos) (D20).
4. **Given** um visitante que fechou o app, **When** ele abre o app novamente, **Then** a tela de login aparece de novo; a escolha de visitante não é lembrada (D22).

---

### User Story 2 - Ações de conta ocultas para o visitante (Priority: P2)

Enquanto navega como visitante, a pessoa não vê nenhuma ação que dependa de uma conta: favoritar, adicionar à watchlist, avaliar e o acesso ao Perfil.

**Why this priority**: Evita que o visitante toque em algo que não pode funcionar sem conta e receba erros (D21). Depende da História 1 para existir um visitante.

**Independent Test**: Entrar como visitante e percorrer Home, detalhe de filme, detalhe de série e menu lateral, conferindo que nenhuma ação de conta aparece.

**Acceptance Scenarios**:

1. **Given** um visitante no detalhe de um filme, **When** a tela carrega, **Then** o botão de favorito não é exibido (D21).
2. **Given** um visitante no detalhe de um filme ou série, **When** a tela carrega, **Then** as ações de watchlist e de avaliação não são exibidas, quando essas funcionalidades existirem (D21).
3. **Given** um visitante, **When** ele abre o menu lateral, **Then** o item "Profile" não aparece e o item "Exit" é substituído por "Entrar" (D21).
4. **Given** um visitante, **When** ele acessa diretamente um endereço de área restrita (ex.: o Perfil, pelo link na versão Web), **Then** o app abre a Home em modo visitante, sem exibir a área restrita.
5. **Given** um visitante com o menu lateral aberto, **When** o cabeçalho do menu é exibido, **Then** ele mostra um ícone de pessoa padrão e o texto "Olá, visitante".

---

### User Story 3 - Sair do modo visitante e entrar na conta (Priority: P3)

O visitante decide usar a conta: toca em "Entrar" no menu lateral, faz login e passa a ter acesso às ações de conta.

**Why this priority**: Fecha o ciclo e converte o visitante em usuário logado, mas o app já é útil sem isso, porque o visitante pode reabrir o app e fazer login.

**Independent Test**: Entrar como visitante, tocar em "Entrar", fazer login com uma conta válida e conferir que favoritar e o Perfil passam a aparecer.

**Acceptance Scenarios**:

1. **Given** um visitante, **When** ele toca em "Entrar" no menu lateral, **Then** a tela de login é exibida.
2. **Given** a tela de login aberta a partir do modo visitante, **When** o login é feito com sucesso, **Then** o usuário é levado à Home e passa a ver as ações de conta.
3. **Given** a tela de login aberta a partir do modo visitante, **When** o login falha, **Then** a mensagem de erro de login atual é exibida e o botão "Continuar sem login" continua disponível.

---

### Edge Cases

- **Sessão salva ao abrir o app:** se há sessão válida, o app segue o fluxo do usuário logado e o visitante não entra em jogo (relaciona-se a D5).
- **Sessão expirada durante o uso:** o usuário volta à tela de login (D31), onde pode escolher "Continuar sem login".
- **Ações de conta em telas de listas:** quando existirem selos ou atalhos de conta nos cards (D24), eles não aparecem para o visitante.
- **Sem conexão:** o visitante recebe o mesmo tratamento de erro de rede que um usuário logado; o modo visitante não altera mensagens de erro do catálogo.
- **Logout:** um usuário logado que faz logout volta à tela de login e pode escolher "Continuar sem login".
- **Nenhum dado de conta para o visitante:** o app não busca favoritos, watchlist nem avaliações enquanto estiver em modo visitante.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A tela de login MUST exibir um botão secundário "Continuar sem login" sempre que não houver sessão de usuário (D22).
- **FR-002**: Ao tocar em "Continuar sem login", o sistema MUST abrir a Home em modo visitante sem solicitar credenciais (D20).
- **FR-003**: O visitante MUST ter acesso de leitura completo à Home (filmes e séries), à busca e aos detalhes de filmes e séries (D20).
- **FR-004**: O sistema MUST NOT criar nem usar uma sessão de convidado do TMDB para o modo visitante (D20).
- **FR-005**: O sistema MUST NOT lembrar a escolha de visitante: ao reabrir o app sem sessão, a tela de login MUST ser exibida (D22).
- **FR-006**: Para o visitante, o sistema MUST ocultar as ações de favoritar, watchlist e avaliação em todas as telas em que existirem (D21).
- **FR-007**: Para o visitante, o menu lateral MUST ocultar o item "Profile" e MUST exibir "Entrar" no lugar de "Exit" (D21).
- **FR-008**: O item "Entrar" MUST levar à tela de login (D21).
- **FR-009**: Após um login bem-sucedido iniciado pelo modo visitante, o sistema MUST levar o usuário à Home e exibir as ações de conta.
- **FR-010**: O acesso direto de um visitante a uma área restrita MUST levar à Home em modo visitante, sem exibir a área restrita (I9).
- **FR-011**: O cabeçalho do menu lateral do visitante MUST exibir um ícone de pessoa padrão e o texto "Olá, visitante", sem buscar dados de usuário.
- **FR-012**: O sistema MUST NOT consultar dados de conta (favoritos, watchlist, avaliações, dados do usuário) enquanto estiver em modo visitante (I7).

### Key Entities

- **Modo de acesso**: como a pessoa está usando o app nesta abertura — *usuário logado* (tem sessão) ou *visitante* (escolheu continuar sem login). Define quais ações e telas ficam disponíveis. Não é persistido entre aberturas.
- **Área restrita**: telas ou ações que exigem conta — Perfil, favoritar, watchlist e avaliação.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A partir da tela de login, um visitante chega à lista de filmes com **1 toque**, sem digitar nada.
- **SC-002**: Em uma navegação completa como visitante (Home, busca, detalhe de filme, detalhe de série, menu lateral), **0** ações de conta ficam visíveis.
- **SC-003**: Em modo visitante, **0** consultas de dados de conta são feitas.
- **SC-004**: Em **100%** das reaberturas do app sem sessão, a tela de login é exibida.
- **SC-005**: Um visitante consegue entrar na conta pelo menu lateral em no máximo **2 toques** antes de digitar as credenciais.

## Assumptions

- O item "Settings" do menu lateral continua visível para o visitante, porque idioma e tema não dependem de conta (D25).
- Watchlist (D11) e avaliações (D3, D24) ainda não existem; os requisitos de ocultação valem para quando forem implementadas, sem trabalho extra nesta feature.
- O comportamento atual já esconde o botão de favorito no detalhe de filme quando não há sessão; esta feature o mantém.
- O catálogo continua acessível sem conta porque o acesso ao TMDB é feito com a credencial do próprio app, não do usuário (D18, D27).
- Endereços diretos de telas só existem na versão Web depois da migração de navegação (D30); até lá, o FR-010 se aplica apenas ao que já é alcançável.
- O ícone de favorito das séries é apenas indicativo e está fora do escopo (séries fora do escopo no momento).
- Os textos ("Continuar sem login", "Entrar") seguem o idioma da interface quando o multi-idioma existir (D13).
