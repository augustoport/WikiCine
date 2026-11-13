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
    Future<void> pumpMovie(WidgetTester tester, String id) async {
      await pumpApp(tester, MovieDetailPage(movieId: id));
      await tester.pumpAndSettle();
    }

    testWidgets('carrega detalhes, créditos e favoritos do filme', (tester) async {
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

    testWidgets('marca o coração quando o filme está nos favoritos', (tester) async {
      deps.user.favorites = [Fixtures.movieA];

      await pumpMovie(tester, '1');

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('coração vazio quando o filme não é favorito', (tester) async {
      deps.user.favorites = [Fixtures.movieA];

      await pumpMovie(tester, '2');

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('falha ao buscar favoritos não impede exibir o filme', (tester) async {
      deps.user.failing.add('getUserMovieFavorites');

      await pumpMovie(tester, '1');

      expect(find.text('Interestelar'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

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

    testWidgets('série não exibe duração nem consulta favoritos', (tester) async {
      await pumpTv(tester, '10');

      expect(find.text('- min'), findsOneWidget);
      expect(deps.user.calls, isEmpty);
    });

    testWidgets('não exibe diretor mesmo que os créditos tragam um', (tester) async {
      // SerieSuccess só carrega o elenco; a página não repassa `director`.
      deps.tv.credits = const Credits(cast: [Fixtures.actor], director: Fixtures.director);

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
