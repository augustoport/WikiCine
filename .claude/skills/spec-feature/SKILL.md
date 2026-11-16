---
name: spec-feature
description: Cria a especificação (spec.md) de uma nova feature do WikiCine no modelo Spec-Driven Development, a partir de uma descrição em linguagem natural, usando o template oficial e as decisões de docs/. Use quando o usuário pedir para especificar, escrever a spec, detalhar requisitos ou iniciar uma nova feature (ex.: "/spec-feature modo visitante", "especifique a watchlist"). Não implementa código.
argument-hint: "<descrição da feature>"
---

# spec-feature — Especificação de feature (Spec-Driven Development)

Entrada do usuário: **$ARGUMENTS**

Esta skill produz **somente a especificação** de uma feature: o **o quê** e o **porquê**, nunca o **como**. O planejamento técnico e a implementação vêm depois, em outra etapa.

## Arquivos desta skill

| Arquivo | Uso |
|---|---|
| `templates/spec-template.md` | Template oficial da spec. Copie a estrutura **sem alterar títulos, ordem nem marcações** (`*(mandatory)*`). |
| `templates/requirements-checklist.md` | Checklist de qualidade a preencher para cada spec. |

## Saídas

```
specs/
├── README.md                          # índice de todas as specs (criar se não existir)
└── NNN-nome-da-feature/
    ├── spec.md                        # a especificação
    └── checklists/
        └── requirements.md            # checklist de qualidade preenchido
```

## Regras de escrita

- **Idioma:** títulos e rótulos do template ficam como estão (em inglês); **o conteúdo é escrito em português (pt-BR)**, como o restante da documentação do projeto.
- **Sem implementação:** não citar Flutter, Dart, cubit, use case, repositório, `go_router`, endpoints, nomes de classes ou pacotes. Descreva comportamento observável pelo usuário e regras de negócio.
- **Fonte da verdade:** as decisões `Dn` e impactos `In` de `docs/OBJETIVO_DO_SISTEMA.md` prevalecem sobre qualquer suposição. Requisitos derivados delas citam o ID entre parênteses, ex.: `(D21)`.
- **Nunca inventar regra de negócio.** O que não estiver na entrada nem nos documentos vira:
  - uma **Assumption** quando existir um padrão razoável e de baixo impacto; ou
  - um `[NEEDS CLARIFICATION: pergunta objetiva]` quando a escolha mudar o escopo, a experiência do usuário ou a segurança. **No máximo 3 marcadores**, priorizados por impacto.
- **User stories:** ordenadas por prioridade (P1 = mais crítica), cada uma **testável e entregável sozinha**. A P1, isolada, deve ser um MVP demonstrável.
- **Cenários de aceite** sempre no formato **Given / When / Then**, com estados e resultados concretos (textos exibidos, telas, valores).
- **Requisitos funcionais:** numerados `FR-001`…, testáveis, sem ambiguidade ("deve", não "deveria"; nada de "rápido", "intuitivo" sem métrica).
- **Critérios de sucesso:** `SC-001`…, mensuráveis e independentes de tecnologia (tempo, contagem, percentual, presença/ausência observável).
- **Remova** os comentários HTML e todos os exemplos/placeholders do template. Seções opcionais sem conteúdo (ex.: Key Entities) devem ser removidas, não deixadas vazias.

## Processo

### 1. Entender a entrada
- Se `$ARGUMENTS` estiver vazio, pergunte ao usuário qual feature especificar e pare.
- Extraia: atores, ações, dados envolvidos, restrições e o que está explicitamente fora do escopo.

### 2. Carregar o contexto do projeto
Leia, nesta ordem:
1. `docs/OBJETIVO_DO_SISTEMA.md` — seções 4 (fluxos), 5 (funcionalidades), **8 (decisões e impactos)** e 9 (pendências).
2. `docs/ARQUITETURA_DO_SISTEMA.md` — seção 7 (bugs, violações e riscos) e seção 10 (diretrizes), só para identificar restrições e dependências; **não** copie detalhes técnicos para a spec.
3. Os `README.md` dos módulos de `lib/` afetados, para saber **o que já existe** e não especificar como novo algo que já está pronto.
4. `specs/README.md` e as specs existentes, para evitar duplicidade e registrar dependências entre features.

Monte uma lista interna: decisões aplicáveis, o que já está implementado, o que depende de decisões ainda não implementadas.

**Conflito:** se a entrada contradiz uma decisão `Dn`, **pare e pergunte** ao usuário qual vale (a decisão pode precisar ser atualizada em `docs/`). Não escolha sozinho.

### 3. Definir número e nome
- `NNN` = maior número em `specs/` + 1, com 3 dígitos (`001` se não houver nenhuma).
- Nome curto em kebab-case, em português e sem acentos, com 2 a 4 palavras (ex.: `modo-visitante`, `watchlist`, `avaliacao-de-titulos`).
- Branch sugerida: `NNN-nome-da-feature`. **Não crie a branch** a menos que o usuário peça; apenas preencha o campo.

### 4. Escrever a spec
Copie `templates/spec-template.md` para `specs/NNN-nome/spec.md` e preencha:
- **Cabeçalho:** nome da feature, branch sugerida, data de hoje (`AAAA-MM-DD`), `Status: Draft`, e a descrição original do usuário em `Input`.
- **User Scenarios & Testing:** quantas stories forem necessárias (não force 3). Inclua em cada uma "Why this priority" e "Independent Test".
- **Edge Cases:** limites, erros, estados vazios, perda de conexão, sessão ausente/expirada, permissões (logado × visitante), dados ausentes da API.
- **Functional Requirements:** cubra todos os cenários; cite `Dn`/`In` de origem.
- **Key Entities:** só se a feature envolver dados; descreva significado e relações, sem tipos nem campos técnicos.
- **Success Criteria:** ao menos 3, mensuráveis.
- **Assumptions:** padrões adotados, limites de escopo, dependências de outras features/decisões (com ID) e do que já existe no app.

### 5. Validar com o checklist
- Copie `templates/requirements-checklist.md` para `specs/NNN-nome/checklists/requirements.md` e avalie cada item contra a spec.
- Corrija a spec e reavalie (no máximo 3 rodadas). Registre em **Notas** o que não pôde ser resolvido.

### 6. Esclarecer as dúvidas
Se restarem marcadores `[NEEDS CLARIFICATION]`:
- Pergunte ao usuário **de uma vez só** (até 3 perguntas), cada uma com 2 a 4 opções concretas e o impacto de cada opção. Use a ferramenta de perguntas ao usuário quando disponível.
- Aplique as respostas: substitua cada marcador pelo texto final e acrescente, logo após o cabeçalho, a seção:

  ```markdown
  ## Clarifications

  ### Session AAAA-MM-DD
  - Q: <pergunta> → A: <resposta>
  ```
- Reavalie o checklist. Se uma resposta criar uma nova regra de produto, sugira registrá-la como decisão em `docs/OBJETIVO_DO_SISTEMA.md` (não altere `docs/` sem confirmação).

### 7. Atualizar o índice
Em `specs/README.md`, mantenha uma tabela com: `ID`, `Feature` (link para a spec), `Status`, `Decisões` (IDs), `Branch sugerida`, `Depende de`. Crie o arquivo com um parágrafo curto explicando a pasta se ele não existir.

### 8. Reportar
Responda ao usuário com:
- caminho da spec e do checklist;
- resumo das user stories (título e prioridade);
- perguntas respondidas e suposições relevantes;
- resultado do checklist (itens reprovados, se houver);
- próximo passo sugerido: planejamento técnico da feature (`plan`), respeitando `docs/ARQUITETURA_DO_SISTEMA.md` seção 10.

## Status da spec
| Status | Quando |
|---|---|
| `Draft` | Criada por esta skill. |
| `Clarified` | Sem marcadores `[NEEDS CLARIFICATION]` e checklist aprovado. |
| `Approved` | O usuário aprovou explicitamente. |
| `Implemented` | Código entregue e testes passando (atualizado na etapa de implementação). |

Esta skill termina em `Draft` ou `Clarified`. Só marque `Approved` se o usuário disser que aprova.
