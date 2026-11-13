# `lib/` — Código-fonte do aplicativo

> Raiz do código Dart do pacote `cinerating` (produto **WikiCine**).
> Documentos globais: [`docs/ARQUITETURA_DO_SISTEMA.md`](../docs/ARQUITETURA_DO_SISTEMA.md) · [`docs/OBJETIVO_DO_SISTEMA.md`](../docs/OBJETIVO_DO_SISTEMA.md)

## Objetivo
Conter todo o código do app Flutter, organizado em Clean Architecture.

## Responsabilidade principal
`main.dart` é o ponto de entrada: monta o grafo de dependências e inicia a UI.

## Funcionalidades existentes
- `main()` → `setupLocator()` → `runApp(MyApp())`.
- `MyApp` → `MaterialApp(title: 'Flutter Demo', theme: ColorScheme.fromSeed(deepPurple), home: LoginPage())`.

## Estrutura
| Pasta | Papel | README |
|---|---|---|
| `core/` | DI, ambiente, tema, código legado | [core](./core/README.md) |
| `domain/` | Entidades, contratos, casos de uso | [domain](./domain/README.md) |
| `data/` | Datasources HTTP, models, repositórios | [data](./data/README.md) |
| `presentation/` | Páginas, widgets, cubits, controllers | [presentation](./presentation/README.md) |

## Dependências
- **Internas:** `core/locator.dart`, `presentation/pages/login_page.dart`.
- **Externas:** `material_ui`.

## Módulos relacionados
Todos (via `core/locator.dart`).

## Pontos de entrada
- `lib/main.dart` → `main()`.

## Fluxos importantes
Inicialização: ver seção 6.1 de [`ARQUITETURA_DO_SISTEMA.md`](../docs/ARQUITETURA_DO_SISTEMA.md).

## Arquivos críticos
- `main.dart`

## Observações técnicas e débitos
- **[Débito]** `title: 'Flutter Demo'` — título padrão do template; difere do nome do produto.
- **[Débito]** O `ThemeData` (seed `deepPurple`) é praticamente ignorado: telas aplicam cores fixas de `AppColors` e `Colors.grey.shade900`.
- **[Risco]** Não chama `WidgetsFlutterBinding.ensureInitialized()` nem `Firebase.initializeApp()`, apesar de `firebase_core` estar em `pubspec.yaml`.
- `lib/firebase_options.dart`, referenciado em `firebase.json`, não existe (está no `.gitignore`).
