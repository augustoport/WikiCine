import 'dart:io';

import 'package:cinerating/presentation/pages/home_page.dart';
import 'package:cinerating/presentation/pages/login_page.dart';
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

  Finder userField() => find.byType(TextField).at(0);
  Finder passwordField() => find.byType(TextField).at(1);

  Future<void> tapLogin(WidgetTester tester) async {
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('exibe campos de usuário/senha, link de cadastro e botão de login', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Não possui conta no TMDB? '), findsOneWidget);
    expect(find.text('Clique aqui'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('verifica sessão existente ao abrir', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    expect(deps.auth.calls, contains('getCurrentUser'));
  });

  testWidgets('campo de senha é oculto e pode ser revelado', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    TextField password() => tester.widget<TextField>(passwordField());
    expect(password().obscureText, isTrue);
    expect(tester.widget<TextField>(userField()).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(password().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('mostra aviso quando algum campo está vazio', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    await tester.enterText(userField(), 'cinefilo');
    await tapLogin(tester);

    expect(find.text('Preencha todos os campos'), findsOneWidget);
    expect(deps.auth.calls, isNot(contains(startsWith('login'))));
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('mostra erro com credenciais inválidas e permanece no login', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    await tester.enterText(userField(), 'cinefilo');
    await tester.enterText(passwordField(), 'senha-errada');
    await tapLogin(tester);

    expect(deps.auth.calls, contains('login:cinefilo'));
    expect(find.text('Usuário/Senha incorreto(s)'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('com credenciais válidas navega para a Home', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    await tester.enterText(userField(), 'cinefilo');
    await tester.enterText(passwordField(), '123456');
    await tapLogin(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text(Fixtures.movieA.title!), findsOneWidget);
  });
}
