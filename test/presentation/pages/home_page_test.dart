import 'dart:io';

import 'package:cinerating/core/locator.dart';
import 'package:cinerating/presentation/controllers/login_controller.dart';
import 'package:cinerating/presentation/pages/home_page.dart';
import 'package:cinerating/presentation/pages/login_page.dart';
import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:cinerating/presentation/pages/profile_page.dart';
import 'package:cinerating/presentation/pages/tv_show_detail_page.dart';
import 'package:cinerating/presentation/widgets/session_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_image_http.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_locator.dart';

void main() {
  late TestDeps deps;

  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  setUp(() async => deps = await setupTestLocator());

  Future<void> pumpHome(WidgetTester tester) async {
    await pumpApp(tester, const HomePage());
    await tester.pumpAndSettle();
  }

  SessionCard sessionCard(WidgetTester tester, String session) =>
      tester.widget<SessionCard>(find.widgetWithText(SessionCard, session));

  Future<void> search(WidgetTester tester, String text) async {
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  group('HomePage', () {
    testWidgets('carrega e exibe filmes ao abrir', (tester) async {
      await pumpHome(tester);

      expect(find.text('WikiCine'), findsOneWidget);
      expect(deps.movies.calls, ['getMovies']);
      for (final movie in Fixtures.movies) {
        expect(find.text(movie.title!), findsOneWidget);
      }
      expect(find.text('8.6'), findsOneWidget);
      expect(sessionCard(tester, 'Movie').active, isTrue);
      expect(sessionCard(tester, 'TV').active, isFalse);
    });

    testWidgets('mostra indicador de carregamento enquanto busca', (tester) async {
      deps.movies.delay = const Duration(milliseconds: 500);
      await pumpApp(tester, const HomePage());
      await tester.pump(); // executa o microtask que dispara getMovies()

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('alterna para séries ao tocar em "TV" e volta para filmes', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('TV'));
      await tester.pumpAndSettle();

      expect(deps.tv.calls, ['getTvShows']);
      expect(find.text(Fixtures.tvA.name!), findsOneWidget);
      expect(find.text(Fixtures.movieA.title!), findsNothing);
      expect(sessionCard(tester, 'TV').active, isTrue);

      await tester.tap(find.text('Movie'));
      await tester.pumpAndSettle();

      expect(find.text(Fixtures.movieA.title!), findsOneWidget);
      expect(sessionCard(tester, 'Movie').active, isTrue);
    });

    testWidgets('pesquisa filmes pelo campo de busca e limpa o campo', (tester) async {
      await pumpHome(tester);

      await search(tester, 'cidade');

      expect(deps.movies.calls, contains('searchMovies:cidade'));
      expect(find.text(Fixtures.movieB.title!), findsOneWidget);
      expect(find.text(Fixtures.movieA.title!), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('pesquisa séries quando a aba TV está ativa', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('TV'));
      await tester.pumpAndSettle();

      await search(tester, 'dark');

      expect(deps.tv.calls, contains('searchTvShows:dark'));
      expect(find.text(Fixtures.tvB.name!), findsOneWidget);
      expect(find.text(Fixtures.tvA.name!), findsNothing);
    });

    testWidgets('busca vazia recarrega a lista completa', (tester) async {
      await pumpHome(tester);

      await search(tester, '');

      expect(deps.movies.calls, ['getMovies', 'getMovies']);
      expect(deps.movies.calls, isNot(contains(startsWith('searchMovies'))));
    });

    testWidgets('exibe mensagem de erro quando a busca de filmes falha', (tester) async {
      deps.movies.failing.add('getMovies');

      await pumpHome(tester);

      expect(find.text('Não foi possível carregar os filmes'), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro quando a busca de séries falha', (tester) async {
      deps.tv.failing.add('getTvShows');
      await pumpHome(tester);

      await tester.tap(find.text('TV'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os programas de TV'), findsOneWidget);
    });

    testWidgets('tocar em um filme abre o detalhe do filme', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text(Fixtures.movieA.title!));
      await tester.pumpAndSettle();

      expect(find.byType(MovieDetailPage), findsOneWidget);
      expect(deps.movies.calls, contains('getMovieDetails:1'));
    });

    testWidgets('tocar em uma série abre o detalhe da série', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('TV'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(Fixtures.tvA.name!));
      await tester.pumpAndSettle();

      expect(find.byType(TvShowDetailPage), findsOneWidget);
      expect(deps.tv.calls, contains('getTvShowDetails:10'));
    });
  });

  group('DrawerWidget', () {
    Future<void> openDrawer(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
    }

    testWidgets('mostra o nome do usuário logado', (tester) async {
      getIt<LoginController>().currentUser = Fixtures.user;
      await pumpHome(tester);

      await openDrawer(tester);

      expect(find.textContaining('Ana Cinéfila', findRichText: true), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      // Usuário já carregado: não precisa consultar a sessão de novo.
      expect(deps.auth.calls, isNot(contains('getCurrentUser')));
    });

    testWidgets('sem usuário em memória, recupera a sessão existente', (tester) async {
      deps.auth.currentUser = Fixtures.user;
      await pumpHome(tester);

      await openDrawer(tester);

      expect(deps.auth.calls, contains('getCurrentUser'));
      expect(find.textContaining('Ana Cinéfila', findRichText: true), findsOneWidget);
    });

    testWidgets('sem sessão, exibe "Usuário" como nome padrão', (tester) async {
      await pumpHome(tester);

      await openDrawer(tester);

      expect(find.textContaining('Usuário', findRichText: true), findsOneWidget);
    });

    testWidgets('"Profile" abre a página de perfil', (tester) async {
      getIt<LoginController>().currentUser = Fixtures.user;
      await pumpHome(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('"Exit" faz logout e volta para o login', (tester) async {
      getIt<LoginController>().currentUser = Fixtures.user;
      await pumpHome(tester);
      await openDrawer(tester);

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(deps.auth.calls, contains('logout'));
      expect(getIt<LoginController>().currentUser, isNull);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });
  });
}
