# Specification Quality Checklist: Modo visitante (guest)

**Purpose**: Validar a completude e a qualidade da especificação antes do planejamento técnico
**Created**: 2026-11-16
**Feature**: [spec.md](../spec.md)

## Conteúdo

- [x] Sem detalhes de implementação (linguagem, framework, classes, endpoints, pacotes)
- [x] Focado no valor para o usuário e nas regras de negócio
- [x] Legível por alguém sem conhecimento técnico
- [x] Todas as seções obrigatórias preenchidas; nenhum placeholder `[...]` do template restante

## Completude dos requisitos

- [x] No máximo 3 marcadores `[NEEDS CLARIFICATION]`, e todos resolvidos antes de sair de Draft
- [x] Cada requisito é testável e não ambíguo
- [x] Critérios de sucesso mensuráveis e sem tecnologia
- [x] Toda user story tem prioridade, teste independente e cenários Given/When/Then
- [x] Casos de borda identificados
- [x] Escopo delimitado (o que está fora consta em Assumptions)
- [x] Dependências e premissas listadas

## Coerência com a documentação oficial

- [x] Nenhum requisito contradiz uma decisão `Dn` de `docs/OBJETIVO_DO_SISTEMA.md`
- [x] Requisitos derivados de decisões citam o ID (`D20`, `I9`…)
- [x] Dependências de decisões ainda não implementadas estão em Assumptions
- [x] Bugs/riscos relacionados da `docs/ARQUITETURA_DO_SISTEMA.md` foram considerados

## Prontidão

- [x] Todo requisito funcional é coberto por ao menos um cenário de aceite
- [x] A user story P1, sozinha, entrega um MVP demonstrável

## Notas

- Rodada 1 (Draft): 3 dúvidas abertas (destino pós-login, acesso direto a área restrita, cabeçalho do menu). Item "No máximo 3 marcadores… resolvidos" reprovado.
- Rodada 2 (Clarified): dúvidas respondidas pelo mantenedor em 2026-11-16 (seção Clarifications da spec). Todos os itens aprovados.
- FR-004 e FR-012 citam "sessão de convidado" e "dados de conta" como regras de negócio (D20, I7), não como detalhe técnico.
- As três respostas são regras de produto novas; sugerido registrá-las em `docs/OBJETIVO_DO_SISTEMA.md` como decisões.
