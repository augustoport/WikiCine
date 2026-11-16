import 'dart:io';

import 'package:cinerating/domain/entities/credits.dart';
import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:cinerating/presentation/pages/tv_show_detail_page.dart';
import 'package:cinerating/presentation/widgets/content_detail.dart';
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

  group('MovieDetailPage', () {
    // Usuário logado por padrão; os testes de visitante limpam a sessão.
    setUp(() => deps.auth.currentUser = Fixtures.user);

    Future<void> pumpMovie(WidgetTester tester, String id) async {
      await pumpApp(tester, MovieDetailPage(movieId: id));
      await tester.pumpAndSettle();
    }

    Finder toast(String text) =>
        find.descendant(of: find.byType(SnackBar), matching: find.text(text));

    testWidgets('carrega detalhes, créditos e favoritos do filme', (
      tester,
    ) async {
      await pumpMovie(tester, '1');

      expect(deps.movies.calls, ['getMovieDetails:1', 'getMovieCredits:1']);
      expect(deps.user.calls, ['getUserMovieFavorites']);
      expect(find.byType(ContentDetail), findsOneWidget);
      expect(find.text('Interestelar'), findsOneWidget);
    });

    testWidgets('exibe apenas atores no elenco e o diretor', (tester) async {
      await pumpMovie(tester, '1');

      expect(find.text('Matthew McConaughey'), findsOneWidget);
      expect(find.text('as Cooper'), findsOneWidget);
      // Hans Zimmer é da equipe (Sound) e é filtrado pelo GetMovieCrewUseCase.
      expect(find.text('Hans Zimmer'), findsNothing);
      expect(find.text('Directed by:'), findsOneWidget);
      expect(find.text('Christopher Nolan'), findsOneWidget);
    });

    testWidgets('coração preenchido quando o id está na lista de favoritos', (
      tester,
    ) async {
      deps.user.favorites = [Fixtures.movieA];

      await pumpMovie(tester, '1');

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('coração vazado quando o id não está na lista de favoritos', (
      tester,
    ) async {
      deps.user.favorites = [Fixtures.movieA];

      await pumpMovie(tester, '2');

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('falha ao buscar favoritos não impede exibir o filme', (
      tester,
    ) async {
      deps.user.failing.add('getUserMovieFavorites');

      await pumpMovie(tester, '1');

      expect(find.text('Interestelar'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    group('visitante (guest)', () {
      setUp(() => deps.auth.currentUser = null);

      testWidgets('não exibe o coração nem consulta favoritos', (tester) async {
        await pumpMovie(tester, '1');

        expect(find.text('Interestelar'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
        expect(deps.user.calls, isEmpty);
      });
    });

    testWidgets(
      'tocar no coração vazado adiciona, preenche o coração e mostra toast verde',
      (tester) async {
        deps.user.favorites = [Fixtures.movieA];
        await pumpMovie(tester, '2');

        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pump(); // conclui o caso de uso e o ListenableBuilder
        await tester.pump(); // anima a entrada do SnackBar

        expect(deps.user.calls, [
          'getUserMovieFavorites',
          'setMovieFavorite:2:true',
        ]);
        expect(deps.user.favorites.map((m) => m.id), contains(2));
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
        expect(toast('Adicionado com sucesso'), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          Colors.green,
        );
      },
    );

    testWidgets(
      'tocar no coração preenchido remove, esvazia o coração e mostra toast verde',
      (tester) async {
        deps.user.favorites = [Fixtures.movieA];
        await pumpMovie(tester, '1');

        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pump();
        await tester.pump();

        expect(deps.user.calls, [
          'getUserMovieFavorites',
          'setMovieFavorite:1:false',
        ]);
        expect(deps.user.favorites.map((m) => m.id), isNot(contains(1)));
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
        expect(toast('Removido com sucesso'), findsOneWidget);
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          Colors.green,
        );
      },
    );

    testWidgets('favoritar não recarrega a tela (sem loading)', (tester) async {
      await pumpMovie(tester, '2');

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(deps.movies.calls, ['getMovieDetails:2', 'getMovieCredits:2']);
    });

    testWidgets(
      'falha ao adicionar mantém o coração vazado e mostra toast vermelho',
      (tester) async {
        deps.user.failing.add('setMovieFavorite');
        await pumpMovie(tester, '2');

        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pump();
        await tester.pump();

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(
          toast('Não foi possível adicionar o filme aos favoritos'),
          findsOneWidget,
        );
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          Colors.red,
        );
      },
    );

    testWidgets(
      'falha ao remover mantém o coração preenchido e mostra toast vermelho',
      (tester) async {
        deps.user.favorites = [Fixtures.movieA];
        deps.user.failing.add('setMovieFavorite');
        await pumpMovie(tester, '1');

        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pump();
        await tester.pump();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(
          toast('Não foi possível remover o filme dos favoritos'),
          findsOneWidget,
        );
        expect(
          tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
          Colors.red,
        );
      },
    );

    testWidgets('mostra "Error" quando os detalhes falham', (tester) async {
      deps.movies.failing.add('getMovieDetails');

      await pumpMovie(tester, '1');

      expect(find.text('Error'), findsOneWidget);
      expect(find.byType(ContentDetail), findsNothing);
    });

    testWidgets('mostra "Error" quando os créditos falham', (tester) async {
      deps.movies.failing.add('getMovieCredits');

      await pumpMovie(tester, '1');

      expect(find.text('Error'), findsOneWidget);
    });
  });

  group('TvShowDetailPage', () {
    Future<void> pumpTv(WidgetTester tester, String id) async {
      await pumpApp(tester, TvShowDetailPage(id: id));
      await tester.pumpAndSettle();
    }

    testWidgets('carrega detalhes e elenco da série', (tester) async {
      await pumpTv(tester, '10');

      expect(deps.tv.calls, ['getTvShowDetails:10', 'getTvShowCredits:10']);
      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('20/01/2008'), findsOneWidget);
      expect(find.text('Matthew McConaughey'), findsOneWidget);
    });

    testWidgets('série não exibe duração nem consulta favoritos', (
      tester,
    ) async {
      await pumpTv(tester, '10');

      expect(find.text('- min'), findsOneWidget);
      expect(deps.user.calls, isEmpty);
    });

    testWidgets('não exibe diretor mesmo que os créditos tragam um', (
      tester,
    ) async {
      // SerieSuccess só carrega o elenco; a página não repassa `director`.
      deps.tv.credits = const Credits(
        cast: [Fixtures.actor],
        director: Fixtures.director,
      );

      await pumpTv(tester, '10');

      expect(find.text('Directed by:'), findsNothing);
      expect(find.text('Christopher Nolan'), findsNothing);
    });

    testWidgets('mostra "Erro" quando os detalhes falham', (tester) async {
      deps.tv.failing.add('getTvShowDetails');

      await pumpTv(tester, '10');

      expect(find.text('Erro'), findsOneWidget);
      expect(find.byType(ContentDetail), findsNothing);
    });
  });
}
