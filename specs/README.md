# `specs/` — Especificações de features (Spec-Driven Development)

Cada feature nova começa por uma especificação que descreve **o quê** e **o porquê**, sem detalhes de implementação. As specs são criadas com a skill [`spec-feature`](../.claude/skills/spec-feature/SKILL.md) (`/spec-feature <descrição>`), a partir do template em `.claude/skills/spec-feature/templates/`, e seguem as decisões de [`docs/OBJETIVO_DO_SISTEMA.md`](../docs/OBJETIVO_DO_SISTEMA.md).

Estrutura de cada feature: `NNN-nome/spec.md`, `NNN-nome/checklists/requirements.md` e, após o planejamento, `NNN-nome/plan.md`.

Status: `Draft` → `Clarified` → `Approved` → `Implemented`.

| ID | Feature | Status | Decisões | Branch sugerida | Depende de |
|---|---|---|---|---|---|
| 001 | [Modo visitante (guest)](./001-modo-visitante/spec.md) · [plano](./001-modo-visitante/plan.md) | Implemented (2026-11-17) | D5, D20 e D22 (revisadas), D21, I7, I9 | `001-modo-visitante` | — (integra-se a D30 e D31 quando existirem) |
