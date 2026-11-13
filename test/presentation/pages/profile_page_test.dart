import 'dart:io';

import 'package:cinerating/core/locator.dart';
import 'package:cinerating/presentation/controllers/login_controller.dart';
import 'package:cinerating/presentation/pages/movie_detail_page.dart';
import 'package:cinerating/presentation/pages/profile_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_image_http.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_locator.dart';

void main() {
  late TestDeps deps;

  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  setUp(() async {
    deps = await setupTestLocator();
    getIt<LoginController>().currentUser = Fixtures.user;
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    await pumpApp(tester, const ProfilePage());
    await tester.pumpAndSettle();
  }

  testWidgets('exibe nome e username do usuário logado', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Ana Cinéfila'), findsOneWidget);
    expect(find.text('cinefilo'), findsOneWidget);
  });

  testWidgets('carrega e lista os filmes favoritos', (tester) async {
    deps.user.favorites = Fixtures.movies;

    await pumpProfile(tester);

    expect(deps.user.calls, ['getUserMovieFavorites']);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Interestelar'), findsOneWidget);
    expect(find.text('Cidade de Deus'), findsOneWidget);
  });

  testWidgets('lista vazia mostra só o título da seção', (tester) async {
    deps.user.favorites = [];

    await pumpProfile(tester);

    expect(find.text('Favorites'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Favorites), matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('mostra erro quando os favoritos não carregam', (tester) async {
    deps.user.failing.add('getUserMovieFavorites');

    await pumpProfile(tester);

    expect(find.text('Error loading profile'), findsOneWidget);
    expect(find.text('Favorites'), findsNothing);
  });

  testWidgets('tocar em um favorito abre o detalhe do filme', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('Interestelar'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailPage), findsOneWidget);
    expect(deps.movies.calls, contains('getMovieDetails:1'));
  });

  testWidgets('botão voltar fecha o perfil', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: const Text('abrir perfil'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir perfil'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsNothing);
    expect(find.text('abrir perfil'), findsOneWidget);
  });
}
