import 'dart:io';

import 'package:cinerating/main.dart';
import 'package:cinerating/presentation/pages/home_page.dart';
import 'package:cinerating/presentation/pages/login_page.dart';
import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:cinerating/presentation/pages/profile_page.dart';
import 'package:cinerating/presentation/pages/tv_show_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/helpers/fake_image_http.dart';
import '../test/helpers/fixtures.dart';
import '../test/helpers/test_locator.dart';

/// Fluxo ponta a ponta no aparelho/emulador, com o app real (`MyApp`) e
/// repositórios falsos no lugar da API do TMDB.
///
/// Execução: `flutter test integration_test -d <device>`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestDeps deps;

  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  setUp(() async => deps = await setupTestLocator());

  /// Fecha o teclado virtual e espera a animação dele terminar. No aparelho o
  /// teclado abre ao digitar e desloca/esconde os botões do login; tocar com
  /// ele animando erra o alvo.
  Future<void> closeKeyboard(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 30 && tester.view.viewInsets.bottom > 0; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await closeKeyboard(tester);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Foca o campo com um toque antes de digitar: depois de [closeKeyboard]
  /// o campo perdeu o foco e o texto digitado não chegaria a ele.
  Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller?.text, text);
  }

  testWidgets('login → filmes → detalhe → séries → perfil → logout', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Login com senha errada mantém na tela de login.
    expect(find.byType(LoginPage), findsOneWidget);
    await typeInto(tester, find.byType(TextField).at(0), 'cinefilo');
    await typeInto(tester, find.byType(TextField).at(1), 'errada');
    await tapAndSettle(tester, find.text('Login'));
    expect(find.text('Usuário/Senha incorreto(s)'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);

    // Login válido leva à Home com os filmes.
    await typeInto(tester, find.byType(TextField).at(1), '123456');
    await tapAndSettle(tester, find.text('Login'));
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);

    // Busca de filmes.
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'cidade');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(deps.movies.calls, contains('searchMovies:cidade'));
    expect(find.text('Cidade de Deus'), findsOneWidget);
    expect(find.text('Interestelar'), findsNothing);

    // Detalhe do filme (favorito marcado, elenco e diretor).
    await tapAndSettle(tester, find.text('Cidade de Deus'));
    expect(find.byType(MovieDetailPage), findsOneWidget);
    expect(find.text('Crime'), findsOneWidget);
    expect(find.text('Christopher Nolan'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Aba TV e detalhe da série.
    await tapAndSettle(tester, find.text('TV'));
    expect(find.text('Breaking Bad'), findsOneWidget);
    await tapAndSettle(tester, find.text('Breaking Bad'));
    expect(find.byType(TvShowDetailPage), findsOneWidget);
    expect(find.text('20/01/2008'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Drawer → Perfil com favoritos → detalhe do favorito.
    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    expect(
      find.textContaining('Ana Cinéfila', findRichText: true),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Profile'));
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Ana Cinéfila'), findsOneWidget);
    await tapAndSettle(tester, find.text('Interestelar'));
    expect(find.byType(MovieDetailPage), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_ios));

    // Logout volta ao login.
    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    await tapAndSettle(tester, find.text('Exit'));
    expect(deps.auth.calls, contains('logout'));
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  /// Spec 001 (modo visitante): plano, seção 4.3.
  testWidgets('visitante → catálogo → entrar → logado', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Um toque leva o visitante à Home (SC-001).
    expect(find.byType(LoginPage), findsOneWidget);
    await tapAndSettle(tester, find.text('Continuar sem login'));
    expect(deps.auth.calls, contains('startGuestSession'));
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);

    // Detalhe do filme sem o coração (FR-006).
    await tapAndSettle(tester, find.text('Interestelar'));
    expect(find.byType(MovieDetailPage), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Menu do visitante (FR-007, FR-011) → "Entrar" (FR-008).
    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    expect(
      find.textContaining('visitante', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Profile'), findsNothing);
    await tapAndSettle(tester, find.text('Entrar'));
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // Login válido → Home com as ações de conta (FR-009).
    await typeInto(tester, find.byType(TextField).at(0), 'cinefilo');
    await typeInto(tester, find.byType(TextField).at(1), '123456');
    await tapAndSettle(tester, find.text('Login'));
    expect(find.byType(HomePage), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    expect(
      find.textContaining('Ana Cinéfila', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    expect(deps.auth.guestSession, isFalse, reason: 'login descarta convidado');
    expect(deps.user.calls, isEmpty, reason: 'nada de conta antes do login');
  });

  /// Spec 001: reabrir o app com sessão válida vai direto para a Home.
  testWidgets('reabrir com sessão de convidado → Home como visitante', (
    tester,
  ) async {
    deps.auth.guestSession = true;

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    expect(
      find.textContaining('visitante', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('reabrir com sessão de conta → Home logado', (tester) async {
    deps.auth.currentUser = Fixtures.user;

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    expect(find.text('Profile'), findsOneWidget);
  });
}
