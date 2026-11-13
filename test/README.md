# `test/` — Testes automatizados

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../docs/ARQUITETURA_DO_SISTEMA.md) seções 7.3, 7.4 (S12), 9, 10.

## Objetivo
Abrigar os testes do app (`flutter test`).

## Responsabilidade principal
Garantir o comportamento das camadas `domain`, `data` e `presentation`.

## Funcionalidades existentes
| Arquivo | Conteúdo |
|---|---|
| `home_test.dart` | `void main() {}` — vazio |
| `login_test.dart` | `void main() {}` — vazio |

**Cobertura atual: nenhuma.**

## Dependências
- **Externas:** `flutter_test` (dev_dependency). Não há biblioteca de mocks (`mocktail`/`mockito`) nem `bloc_test`.

## Módulos relacionados
Todos os módulos de `lib/` (alvo dos testes).

## Pontos de entrada
`flutter test`.

## Fluxos importantes
Nenhum implementado.

## Arquivos críticos
Nenhum.

## Observações técnicas e débitos
- **[Débito S12]** Nenhum teste existe.
- **[Débito]** A resolução de dependências via `getIt` dentro dos construtores (V4) obriga a configurar o locator com *fakes* antes de cada teste; injeção por construtor simplificaria.
- **Prioridade sugerida de cobertura:**
  1. `data/models/*` — `fromMap` com JSON reais do TMDB (incluindo campos nulos/strings vazias).
  2. `MovieCubit` — montagem de elenco/diretor (bug B1) e `isFavorite`.
  3. `HomeCubit` + `HomeController.setList` — transições de estado e busca vazia.
  4. `AuthApi` — `getCurrentUser` com e sem sessão; `logout`.
  5. Widgets: `ContentDetail` com datas nulas (bug B3).
- **Convenção proposta:** espelhar a estrutura de `lib/` (`test/domain/...`, `test/data/...`, `test/presentation/...`).
