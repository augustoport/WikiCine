import 'dart:io';

import 'package:cinerating/domain/entities/movie.dart';
import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:cinerating/presentation/pages/tv_show_detail_page.dart';
import 'package:cinerating/presentation/widgets/content_list.dart';
import 'package:cinerating/presentation/widgets/movie_card.dart';
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

  Future<void> pumpList(
    WidgetTester tester, {
    required List<dynamic> content,
    required String type,
    RefreshCallback? onRefresh,
  }) async {
    await pumpInScaffold(
      tester,
      ContentList(content: content, type: type, onRefresh: onRefresh ?? () async {}),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renderiza um card por filme com título e nota', (tester) async {
    await pumpList(tester, content: Fixtures.movies, type: 'movie');

    expect(find.byType(MovieCard), findsNWidgets(2));
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('8.6'), findsOneWidget);
    expect(find.text('Cidade de Deus'), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
  });

  testWidgets('usa "name" para séries e nota 0.0 quando ausente', (tester) async {
    await pumpList(
      tester,
      content: [...Fixtures.tvShows, Movie(id: 3, name: 'Sem nota')],
      type: 'tv',
    );

    expect(find.text('Breaking Bad'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Sem nota'), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);
  });

  testWidgets('card sem pôster mostra ícone de câmera', (tester) async {
    await pumpList(tester, content: [Fixtures.movieA], type: 'movie');

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('lista vazia não renderiza cards', (tester) async {
    await pumpList(tester, content: const [], type: 'movie');

    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('puxar para atualizar chama onRefresh', (tester) async {
    var refreshed = 0;
    await pumpList(
      tester,
      content: Fixtures.movies,
      type: 'movie',
      onRefresh: () async => refreshed++,
    );

    await tester.fling(find.text('Interestelar'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(refreshed, 1);
  });

  testWidgets('tipo "movie" navega para MovieDetailPage com o id', (tester) async {
    await pumpList(tester, content: Fixtures.movies, type: 'movie');

    await tester.tap(find.text('Cidade de Deus'));
    await tester.pumpAndSettle();

    final page = tester.widget<MovieDetailPage>(find.byType(MovieDetailPage));
    expect(page.movieId, '2');
    expect(deps.movies.calls, contains('getMovieDetails:2'));
  });

  testWidgets('tipo "tv" navega para TvShowDetailPage com o id', (tester) async {
    await pumpList(tester, content: Fixtures.tvShows, type: 'tv');

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final page = tester.widget<TvShowDetailPage>(find.byType(TvShowDetailPage));
    expect(page.id, '11');
  });
}
