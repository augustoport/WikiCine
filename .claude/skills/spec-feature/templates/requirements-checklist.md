# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validar a completude e a qualidade da especificação antes do planejamento técnico
**Created**: [DATE]
**Feature**: [link para spec.md]

## Conteúdo

- [ ] Sem detalhes de implementação (linguagem, framework, classes, endpoints, pacotes)
- [ ] Focado no valor para o usuário e nas regras de negócio
- [ ] Legível por alguém sem conhecimento técnico
- [ ] Todas as seções obrigatórias preenchidas; nenhum placeholder `[...]` do template restante

## Completude dos requisitos

- [ ] No máximo 3 marcadores `[NEEDS CLARIFICATION]`, e todos resolvidos antes de sair de Draft
- [ ] Cada requisito é testável e não ambíguo
- [ ] Critérios de sucesso mensuráveis e sem tecnologia
- [ ] Toda user story tem prioridade, teste independente e cenários Given/When/Then
- [ ] Casos de borda identificados
- [ ] Escopo delimitado (o que está fora consta em Assumptions)
- [ ] Dependências e premissas listadas

## Coerência com a documentação oficial

- [ ] Nenhum requisito contradiz uma decisão `Dn` de `docs/OBJETIVO_DO_SISTEMA.md`
- [ ] Requisitos derivados de decisões citam o ID (`D20`, `I9`…)
- [ ] Dependências de decisões ainda não implementadas estão em Assumptions
- [ ] Bugs/riscos relacionados da `docs/ARQUITETURA_DO_SISTEMA.md` foram considerados

## Prontidão

- [ ] Todo requisito funcional é coberto por ao menos um cenário de aceite
- [ ] A user story P1, sozinha, entrega um MVP demonstrável

## Notas

- [Itens reprovados e o que foi feito]
