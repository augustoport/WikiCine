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

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('login → filmes → detalhe → séries → perfil → logout', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Login com senha errada mantém na tela de login.
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'cinefilo');
    await tester.enterText(find.byType(TextField).at(1), 'errada');
    await tapAndSettle(tester, find.text('Login'));
    expect(find.text('Usuário/Senha incorreto(s)'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);

    // Login válido leva à Home com os filmes.
    await tester.enterText(find.byType(TextField).at(1), '123456');
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
    expect(find.textContaining('Ana Cinéfila', findRichText: true), findsOneWidget);
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
}
