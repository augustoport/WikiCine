# Feature Specification: Modo visitante (guest)

**Feature Branch**: `001-modo-visitante`

**Created**: 2026-11-16

**Status**: Implemented (2026-11-17; revisada em 2026-11-16, rodada 3)

**Input**: User description: "Modo visitante (guest): permitir acessar o app sem login, conforme as decisões D20, D21 e D22." Revisão do mantenedor: "usar a sessão de convidado do TMDB; com essa sessão, não ir ao login e sim à Home, como uma conta convencional, apenas com as travas de perfil, favoritos e watchlist."

## Clarifications

### Session 2026-11-16
- Q: Depois que o visitante toca em "Entrar" e faz login com sucesso, para onde ele vai? → A: Sempre para a Home.
- Q: Se um visitante acessar diretamente uma área restrita (ex.: link do Perfil na Web), o que acontece? → A: Vai para a Home, como visitante.
- Q: O que o cabeçalho do menu lateral mostra para o visitante? → A: Saudação genérica: ícone de pessoa padrão e "Olá, visitante".

### Session 2026-11-16 (rodada 3, revisão de D20 e D22)
- Q: O visitante usa uma sessão de convidado do TMDB? → A: **Sim.** "Continuar sem login" cria uma sessão de convidado no TMDB. Revoga a parte "não usa sessão guest" da D20.
- Q: A escolha de visitante é lembrada ao reabrir o app? → A: **Sim, enquanto a sessão de convidado for válida**: o app abre direto na Home, como visitante. Revoga a parte "não é lembrada" da D22.
- Q: A sessão de convidado expira (cerca de 24h). O que acontece ao reabrir o app com ela expirada? → A: A sessão é descartada e a tela de login aparece, com "Continuar sem login" para gerar outra.
- Q: Uma sessão de conta salva também abre direto na Home? → A: **Sim.** Qualquer sessão válida salva (conta ou convidado) abre na Home. Antecipa a D5.
- Q: A sessão de convidado do TMDB permite avaliar. O visitante avalia? → A: **Não.** Avaliação continua travada para o visitante (D21 mantida).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Explorar o catálogo sem conta (Priority: P1)

Uma pessoa sem conta no TMDB (ou que não quer entrar agora) abre o app, escolhe "Continuar sem login" na tela de login e navega pelo catálogo: vê as listas de filmes e séries, pesquisa títulos e abre os detalhes, exatamente como um usuário logado. Ao reabrir o app no mesmo dia, ela cai direto na Home, sem passar pelo login.

**Why this priority**: É o objetivo da feature (D20): hoje quem não tem conta não consegue ver nada além da tela de login. Sozinha, esta história já entrega valor e é demonstrável.

**Independent Test**: Abrir o app sem sessão salva, tocar em "Continuar sem login", conferir que Home, busca e detalhes funcionam; fechar e reabrir o app e conferir que ele abre direto na Home.

**Acceptance Scenarios**:

1. **Given** o app aberto sem sessão salva, **When** a tela inicial aparece, **Then** é exibida a tela de login com o botão principal "Login" e o botão secundário "Continuar sem login" (D22).
2. **Given** a tela de login, **When** o usuário toca em "Continuar sem login", **Then** uma sessão de convidado é iniciada e a Home é aberta com a lista de filmes, sem pedir usuário nem senha.
3. **Given** o visitante na Home, **When** ele alterna para séries, pesquisa um título ou abre um card, **Then** o resultado é o mesmo que um usuário logado veria (listas, busca e detalhes completos) (D20).
4. **Given** um visitante com sessão de convidado válida que fechou o app, **When** ele abre o app novamente, **Then** a Home é aberta direto, em modo visitante, sem passar pela tela de login.
5. **Given** um visitante cuja sessão de convidado expirou, **When** ele abre o app novamente, **Then** a tela de login é exibida, com "Continuar sem login" disponível.
6. **Given** a tela de login, **When** não é possível iniciar a sessão de convidado (ex.: sem conexão), **Then** uma mensagem de erro é exibida e o usuário continua na tela de login.

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

**Why this priority**: Fecha o ciclo e converte o visitante em usuário logado, mas o app já é útil sem isso.

**Independent Test**: Entrar como visitante, tocar em "Entrar", fazer login com uma conta válida e conferir que favoritar e o Perfil passam a aparecer.

**Acceptance Scenarios**:

1. **Given** um visitante, **When** ele toca em "Entrar" no menu lateral, **Then** a tela de login é exibida.
2. **Given** a tela de login aberta a partir do modo visitante, **When** o login é feito com sucesso, **Then** o usuário é levado à Home, passa a ver as ações de conta e a sessão de convidado é descartada.
3. **Given** a tela de login aberta a partir do modo visitante, **When** o login falha, **Then** a mensagem de erro de login atual é exibida e o botão "Continuar sem login" continua disponível; tocá-lo volta à Home como visitante, reaproveitando a sessão de convidado ainda válida.

---

### User Story 4 - Abrir o app já com sessão (Priority: P3)

Quem já entrou antes (com conta ou como visitante, com sessão ainda válida) abre o app e vai direto para a Home.

**Why this priority**: Torna o modo visitante lembrado coerente com o usuário logado: nenhum dos dois precisa passar pela tela de login a cada abertura (antecipa a D5).

**Independent Test**: Fazer login com uma conta, fechar e reabrir o app e conferir que a Home abre direto, com as ações de conta.

**Acceptance Scenarios**:

1. **Given** uma sessão de conta salva, **When** o app é aberto, **Then** a Home é exibida direto, com as ações de conta (D5).
2. **Given** nenhuma sessão salva, **When** o app é aberto, **Then** a tela de login é exibida.
3. **Given** a abertura do app, **When** o app ainda está verificando a sessão salva, **Then** uma tela de carregamento é exibida, sem mostrar a tela de login de passagem.

---

### Edge Cases

- **Sessão de conta salva e sessão de convidado ao mesmo tempo:** a de conta prevalece; o app abre como usuário logado.
- **Sessão de conta expirada durante o uso:** o usuário volta à tela de login (D31), onde pode escolher "Continuar sem login".
- **Sessão de convidado expira durante o uso:** o catálogo não depende dela (usa a credencial do app, D18), então a navegação continua; na próxima abertura do app a tela de login aparece.
- **Ações de conta em telas de listas:** quando existirem selos ou atalhos de conta nos cards (D24), eles não aparecem para o visitante.
- **Sem conexão:** o visitante recebe o mesmo tratamento de erro de rede que um usuário logado no catálogo; se não houver conexão ao tocar em "Continuar sem login", ver US1-6.
- **Logout:** um usuário logado que faz logout tem todas as sessões descartadas (conta e convidado) e volta à tela de login.
- **"Entrar" com sessão de convidado ativa:** a sessão de convidado é mantida até o login dar certo; se a pessoa fechar o app na tela de login, reabre como visitante.
- **Nenhum dado de conta para o visitante:** o app não busca favoritos, watchlist, avaliações nem dados do usuário enquanto estiver em modo visitante.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A tela de login MUST exibir um botão secundário "Continuar sem login" sempre que não houver sessão de conta (D22).
- **FR-002**: Ao tocar em "Continuar sem login", o sistema MUST iniciar uma sessão de convidado no TMDB (ou reaproveitar uma ainda válida) e abrir a Home em modo visitante, sem solicitar credenciais (D20, revisada).
- **FR-003**: O visitante MUST ter acesso de leitura completo à Home (filmes e séries), à busca e aos detalhes de filmes e séries (D20).
- **FR-004**: O sistema MUST guardar a sessão de convidado no aparelho junto com sua validade (D20, revisada).
- **FR-005**: Ao abrir o app com uma sessão de convidado válida, o sistema MUST abrir a Home em modo visitante, sem exibir a tela de login (D22, revisada).
- **FR-006**: Para o visitante, o sistema MUST ocultar as ações de favoritar, watchlist e avaliação em todas as telas em que existirem (D21).
- **FR-007**: Para o visitante, o menu lateral MUST ocultar o item "Profile" e MUST exibir "Entrar" no lugar de "Exit" (D21).
- **FR-008**: O item "Entrar" MUST levar à tela de login, sem descartar a sessão de convidado (D21).
- **FR-009**: Após um login bem-sucedido iniciado pelo modo visitante, o sistema MUST levar o usuário à Home, exibir as ações de conta e descartar a sessão de convidado.
- **FR-010**: O acesso direto de um visitante a uma área restrita MUST levar à Home em modo visitante, sem exibir a área restrita (I9).
- **FR-011**: O cabeçalho do menu lateral do visitante MUST exibir um ícone de pessoa padrão e o texto "Olá, visitante", sem buscar dados de usuário.
- **FR-012**: O sistema MUST NOT consultar dados de conta (favoritos, watchlist, avaliações, dados do usuário) enquanto estiver em modo visitante (I7).
- **FR-013**: Ao abrir o app com uma sessão de conta salva, o sistema MUST abrir a Home como usuário logado, sem exibir a tela de login (D5).
- **FR-014**: Ao abrir o app com uma sessão de convidado expirada, o sistema MUST descartá-la e exibir a tela de login.
- **FR-015**: Se a sessão de convidado não puder ser iniciada, o sistema MUST exibir uma mensagem de erro e manter o usuário na tela de login.
- **FR-016**: O logout MUST descartar a sessão de conta e a sessão de convidado.
- **FR-017**: Enquanto verifica a sessão salva na abertura do app, o sistema MUST exibir uma tela de carregamento.

### Key Entities

- **Modo de acesso**: como a pessoa está usando o app — *usuário logado* (tem sessão de conta), *visitante* (tem sessão de convidado válida) ou *sem acesso* (nenhuma sessão válida; vê a tela de login). Define quais ações e telas ficam disponíveis.
- **Sessão de convidado**: identificador fornecido pelo TMDB para quem não tem conta, com data de validade. Guardada no aparelho até expirar, até o login dar certo ou até o logout.
- **Área restrita**: telas ou ações que exigem conta — Perfil, favoritar, watchlist e avaliação.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A partir da tela de login, um visitante chega à lista de filmes com **1 toque**, sem digitar nada.
- **SC-002**: Em uma navegação completa como visitante (Home, busca, detalhe de filme, detalhe de série, menu lateral), **0** ações de conta ficam visíveis.
- **SC-003**: Em modo visitante, **0** consultas de dados de conta são feitas.
- **SC-004**: Em **100%** das reaberturas do app com sessão válida (conta ou convidado), a Home é aberta sem passar pela tela de login; em **100%** das reaberturas sem sessão válida, a tela de login é exibida.
- **SC-005**: Um visitante consegue entrar na conta pelo menu lateral em no máximo **2 toques** antes de digitar as credenciais.

## Assumptions

- O item "Settings" do menu lateral continua visível para o visitante, porque idioma e tema não dependem de conta (D25).
- Watchlist (D11) e avaliações (D3, D24) ainda não existem; os requisitos de ocultação valem para quando forem implementadas, sem trabalho extra nesta feature.
- O comportamento atual já esconde o botão de favorito no detalhe de filme quando não há sessão de conta; esta feature o mantém.
- O catálogo continua acessível sem conta porque o acesso ao TMDB é feito com a credencial do próprio app, não do usuário (D18, D27). Nesta feature, a sessão de convidado identifica o modo visitante; nenhuma chamada do catálogo depende dela.
- A validade da sessão de convidado é a informada pelo TMDB ao criá-la; o app não a renova automaticamente.
- A validade da sessão de conta não é verificada na abertura; uma sessão de conta inválida é tratada pela D31.
- Endereços diretos de telas só existem na versão Web depois da migração de navegação (D30); até lá, o FR-010 se aplica apenas ao que já é alcançável.
- O ícone de favorito das séries é apenas indicativo e está fora do escopo (séries fora do escopo no momento).
- Os textos ("Continuar sem login", "Entrar", "Olá, visitante") seguem o idioma da interface quando o multi-idioma existir (D13).
