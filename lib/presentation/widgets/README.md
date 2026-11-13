# `lib/presentation/widgets/` — Componentes reutilizáveis

> Ref. global: [`ARQUITETURA_DO_SISTEMA.md`](../../../docs/ARQUITETURA_DO_SISTEMA.md) seções 7.1 (B1, B3, B6), 7.2 (V7, V8).

## Objetivo
Concentrar elementos visuais usados por mais de uma tela ou isoláveis.

## Responsabilidade principal
Renderização; idealmente sem lógica de negócio nem navegação.

## Funcionalidades existentes
| Arquivo | Widget | Usado por | Descrição |
|---|---|---|---|
| `content_list.dart` | `ContentList(onRefresh, content, type)` | `HomePage` | Grid 2 colunas com `RefreshIndicator`; tap navega para detalhe de filme/série conforme `type`. |
| `movie_card.dart` | `MovieCard(photo, title, vote)` | `ContentList` | Card com pôster (`CachedNetworkImage`), título e nota. |
| `content_detail.dart` | `ContentDetail(content, type, cast, director, isFavorite)` e `ContentCreditWidget(cast, director)` | `MovieDetailPage`, `TvShowDetailPage` | Backdrop, pôster, título, ícone de favorito, nota/votos, data, duração, gêneros, sinopse, elenco, diretor. |
| `cast_card.dart` | `CastCard(actor, roles)` | `ContentCreditWidget` | Foto e nome do ator + personagem (`roles.first.character` para série, `actor.character` para filme). |
| `navigation_blur.dart` | `NavigationBlur(options)` | `HomePage` | Container com desfoque (`BackdropFilter`). |
| `session_card.dart` | `SessionCard(icon, session, onTap, active)` | `HomePage` | Botão da barra inferior (Movie/TV). |
| `text_field_custom.dart` | `TextFieldCustom(controller, hintText, onChanged, isPassword, ...)` | `LoginPage` | Campo com alternância de visibilidade de senha. |

## Dependências
- **Internas:** `core/shared/themes/app_colors.dart`, `core/locator.dart` (importado em `content_detail.dart`, sem uso), `data/models/crew_model.dart` (`content_detail.dart`), `presentation/pages/{movie_detail_page,tv_show_detail_page}.dart` (`content_list.dart`).
- **Externas:** `material_ui`, `cached_network_image`, `intl`, `dart:ui`.

## Módulos relacionados
- `pages/*` (consumidores).

## Pontos de entrada
Construtores dos widgets.

## Fluxos importantes
- `ContentDetail` decide título (`title` vs `name`), data (`releaseDate` vs `firstAirDate`) e duração (`runtime` vs "-") pela string `type`.

## Arquivos críticos
- `content_detail.dart`

## Observações técnicas e débitos
- **[Bug B3]** `DateFormat.format(content.releaseDate)` sem fallback para filmes com data nula.
- **[Bug B6]** Ícone de favorito com `onTap: () {}`.
- **[Bug B1, efeito]** Bloco "Directed by" nunca aparece para filmes porque o cubit envia diretor "N/A".
- **[Violação V7]** `ContentList` importa páginas e navega; deveria receber um callback `onTap`.
- **[Violação V8]** `content`, `cast`, `director`, `actor`, `roles` tipados como `dynamic`.
- **[Violação R3]** `content_detail.dart` importa `CrewModel` de `data/`.
- **[Débito]** `ContentDetail` usa `ListView.builder(itemCount: 1)` em vez de `SingleChildScrollView`.
- **[Débito]** `if (type == "movie")` e `if (type == "tv")` renderizam o mesmo widget (condição redundante).
- **[Débito]** Condição duplicada `expectedTotalBytes != null && expectedTotalBytes != null` no loader do pôster.
- **[Débito]** `Text(content.title/name)` falha se o valor for `null`.
- **[Débito]** Apenas `MovieCard` usa cache de imagem; demais usam `Image.network`.
- **[Débito]** `TextFieldCustom.onChanged` é obrigatório, mas sempre recebe `(value) {}`.
