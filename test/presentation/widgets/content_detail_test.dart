import 'dart:io';

import 'package:cinerating/domain/entities/credits.dart';
import 'package:cinerating/domain/entities/movie.dart';
import 'package:cinerating/domain/entities/tv_show.dart';
import 'package:cinerating/presentation/widgets/cast_card.dart';
import 'package:cinerating/presentation/widgets/content_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_image_http.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());

  group('ContentDetail (filme)', () {
    Future<void> pumpMovie(
      WidgetTester tester,
      Movie movie, {
      List<CastMember> cast = const [Fixtures.actor],
      CastMember? director = Fixtures.director,
      bool isFavorite = false,
    }) async {
      await pumpInScaffold(
        tester,
        ContentDetail(
          content: movie,
          type: 'movie',
          cast: cast,
          director: director,
          isFavorite: isFavorite,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('exibe título, nota, votos, data, duração, gêneros e sinopse', (tester) async {
      await pumpMovie(tester, Fixtures.movieA);

      expect(find.text('Interestelar'), findsOneWidget);
      expect(find.text('8.6'), findsOneWidget);
      expect(find.text('(32000)'), findsOneWidget);
      expect(find.text('06/11/2014'), findsOneWidget);
      expect(find.text('169 min'), findsOneWidget);
      expect(find.text('Genres:'), findsOneWidget);
      expect(find.text('Ficção científica'), findsOneWidget);
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text(Fixtures.movieA.overview!), findsOneWidget);
    });

    testWidgets('exibe elenco e diretor', (tester) async {
      await pumpMovie(tester, Fixtures.movieA);

      expect(find.text('Cast:'), findsOneWidget);
      expect(find.byType(CastCard), findsOneWidget);
      expect(find.text('Matthew McConaughey'), findsOneWidget);
      expect(find.text('as Cooper'), findsOneWidget);
      expect(find.text('Directed by:'), findsOneWidget);
      expect(find.text('Christopher Nolan'), findsOneWidget);
    });

    testWidgets('omite o bloco "Directed by" quando não há diretor', (tester) async {
      await pumpMovie(tester, Fixtures.movieA, director: null);

      expect(find.text('Directed by:'), findsNothing);
    });

    testWidgets('ícone de favorito reflete isFavorite', (tester) async {
      await pumpMovie(tester, Fixtures.movieA, isFavorite: true);

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.red);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('usa "N/A" para nota, votos e sinopse ausentes', (tester) async {
      await pumpMovie(
        tester,
        Movie(id: 9, title: 'Sem dados', releaseDate: DateTime(2020)),
        cast: const [],
        director: null,
      );

      expect(find.text('N/A'), findsNWidgets(2)); // nota e sinopse
      expect(find.text('(N/A)'), findsOneWidget);
      expect(find.text('null min'), findsOneWidget);
      expect(find.byType(CastCard), findsNothing);
    });

    testWidgets(
      'filme sem data de lançamento não quebra a tela',
      (tester) async {
        await pumpMovie(tester, Movie(id: 9, title: 'Sem data'));

        expect(tester.takeException(), isNull);
        expect(find.text('Sem data'), findsOneWidget);
      },
      skip: true, // Bug B3: `DateFormat.format(content.releaseDate)` com null lança exceção (content_detail.dart:973).
    );
  });

  group('ContentDetail (série)', () {
    Future<void> pumpTv(WidgetTester tester, TvShow show) async {
      await pumpInScaffold(
        tester,
        ContentDetail(content: show, type: 'tv', cast: const [Fixtures.actor]),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('usa name e firstAirDate, sem duração', (tester) async {
      await pumpTv(tester, Fixtures.tvA);

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('20/01/2008'), findsOneWidget);
      expect(find.text('- min'), findsOneWidget);
      expect(find.text('Matthew McConaughey'), findsOneWidget);
    });

    testWidgets('série sem data de estreia usa a data atual', (tester) async {
      await pumpTv(tester, TvShow(id: 99, name: 'Sem data'));

      expect(find.text('Sem data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem favorito marcado por padrão', (tester) async {
      await pumpTv(tester, Fixtures.tvA);

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });

  group('CastCard', () {
    testWidgets('sem foto mostra ícone de pessoa e omite personagem nulo', (tester) async {
      await pumpInScaffold(tester, const CastCard(CastMember(name: 'Figurante')));

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Figurante'), findsOneWidget);
      expect(find.textContaining('as '), findsNothing);
    });

    testWidgets('nome ausente vira "N/A"', (tester) async {
      await pumpInScaffold(tester, const CastCard(CastMember()));

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('com foto carrega imagem de rede', (tester) async {
      await pumpInScaffold(
        tester,
        const CastCard(CastMember(name: 'Ator', profilePath: 'https://example.com/a.jpg')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNothing);
    });
  });
}
