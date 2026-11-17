import 'dart:io';

import 'package:cinerating/presentation/pages/home_page.dart';
import 'package:cinerating/presentation/pages/login_page.dart';
import 'package:cinerating/presentation/pages/splash_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_image_http.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_locator.dart';

/// Spec 001 (modo visitante): plano, seção 4.3, cenários S1–S4.
void main() {
  late TestDeps deps;

  setUpAll(() => HttpOverrides.global = FakeImageHttpOverrides());
  setUp(() async => deps = await setupTestLocator());

  Future<void> pumpSplash(WidgetTester tester) async {
    await pumpApp(tester, const SplashPage());
    await tester.pumpAndSettle();
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }

  // S1 — FR-001, SC-004
  testWidgets('sem sessão, vai para o login', (tester) async {
    await pumpSplash(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(HomePage), findsNothing);
  });

  // S2 — FR-005, SC-004
  testWidgets('com sessão de convidado, vai para a Home como visitante', (
    tester,
  ) async {
    deps.auth.guestSession = true;

    await pumpSplash(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text(Fixtures.movieA.title!), findsOneWidget);

    await openDrawer(tester);
    expect(
      find.textContaining('visitante', findRichText: true),
      findsOneWidget,
    );
    expect(deps.auth.calls, isNot(contains('getCurrentUser')));
  });

  // S3 — FR-013, SC-004
  testWidgets('com sessão de conta, vai para a Home logado', (tester) async {
    deps.auth.currentUser = Fixtures.user;

    await pumpSplash(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    await openDrawer(tester);
    expect(
      find.textContaining('Ana Cinéfila', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Profile'), findsOneWidget);
  });

  // S4 — FR-017
  testWidgets('enquanto verifica a sessão, mostra carregamento', (
    tester,
  ) async {
    deps.auth.delay = const Duration(milliseconds: 300);

    await pumpApp(tester, const SplashPage());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
