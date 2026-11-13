import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Tela lógica de 600x900 (a 3x).
///
/// A fonte usada pelo `flutter test` (Ahem) desenha cada caractere como um
/// quadrado do tamanho da fonte, bem mais larga que a Roboto. Em 360dp,
/// linhas como "Não possui conta no TMDB? Clique aqui" acusariam overflow
/// que não acontece no aparelho real.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1800, 2700);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Monta [home] dentro de um `MaterialApp` em tela de celular.
Future<void> pumpApp(WidgetTester tester, Widget home) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(MaterialApp(home: home));
}

/// Monta [child] dentro de um `Scaffold`, para widgets isolados.
Future<void> pumpInScaffold(WidgetTester tester, Widget child) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(backgroundColor: Colors.black, body: child),
    ),
  );
}
