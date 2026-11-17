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

  testWidgets(
    'exibe campos de usuário/senha, link de cadastro e botão de login',
    (tester) async {
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Usuário'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Não possui conta no TMDB? '), findsOneWidget);
      expect(find.text('Clique aqui'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    },
  );

  testWidgets('verifica sessão existente ao abrir', (tester) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    expect(deps.auth.calls, contains('getAccessMode'));
    // Sem sessão não há usuário para buscar (spec 001, FR-012).
    expect(deps.auth.calls, isNot(contains('getCurrentUser')));
  });

  testWidgets('com sessão salva, carrega o usuário ao abrir', (tester) async {
    deps.auth.currentUser = Fixtures.user;
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

  testWidgets('mostra erro com credenciais inválidas e permanece no login', (
    tester,
  ) async {
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

  testWidgets('erro de login anterior não fica por cima da Home', (
    tester,
  ) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();

    await tester.enterText(userField(), 'cinefilo');
    await tester.enterText(passwordField(), 'senha-errada');
    await tapLogin(tester);
    expect(find.text('Usuário/Senha incorreto(s)'), findsOneWidget);

    await tester.enterText(passwordField(), '123456');
    await tapLogin(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('com o teclado aberto, a tela rola e o login continua tocável', (
    tester,
  ) async {
    await pumpApp(tester, const LoginPage());
    await tester.pumpAndSettle();
    // Teclado deixando ~250dp livres: menos que o conteúdo da tela. (No teste
    // o logo não é decodificado e ocupa 0dp; no Pixel 4 sobram ~500dp com o
    // logo, e o overflow é o mesmo.)
    tester.view.viewInsets = const FakeViewPadding(bottom: 1950);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull); // sem overflow
    await tester.enterText(userField(), 'cinefilo');
    await tester.enterText(passwordField(), '123456');
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tapLogin(tester);

    expect(find.byType(HomePage), findsOneWidget);
  });

  /// Spec 001 (modo visitante): plano, seção 4.3, cenários W1–W4.
  group('modo visitante', () {
    // W1 — FR-001, US1-1
    testWidgets('sem sessão, exibe "Login" e "Continuar sem login"', (
      tester,
    ) async {
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Continuar sem login'), findsOneWidget);
    });

    // W2 — FR-001
    testWidgets('com sessão salva, não exibe "Continuar sem login"', (
      tester,
    ) async {
      deps.auth.currentUser = Fixtures.user;
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Continuar sem login'), findsNothing);
    });

    // W3 — FR-002, FR-003, SC-001
    testWidgets('"Continuar sem login" inicia convidado e abre a Home', (
      tester,
    ) async {
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar sem login'));
      await tester.pumpAndSettle();

      expect(deps.auth.calls, contains('startGuestSession'));
      expect(deps.auth.guestSession, isTrue);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text(Fixtures.movieA.title!), findsOneWidget);
      expect(deps.auth.calls, isNot(contains(startsWith('login'))));
    });

    // W3b — FR-015
    testWidgets('falha ao iniciar convidado mostra erro e fica no login', (
      tester,
    ) async {
      deps.auth.failing.add('startGuestSession');
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar sem login'));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível entrar como visitante'),
        findsOneWidget,
      );
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    // W4 — US3-3
    testWidgets('após login com falha, "Continuar sem login" continua', (
      tester,
    ) async {
      await pumpApp(tester, const LoginPage());
      await tester.pumpAndSettle();

      await tester.enterText(userField(), 'cinefilo');
      await tester.enterText(passwordField(), 'senha-errada');
      await tapLogin(tester);

      expect(find.text('Usuário/Senha incorreto(s)'), findsOneWidget);
      expect(find.text('Continuar sem login'), findsOneWidget);
    });
  });
}
