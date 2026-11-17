import 'package:cinerating/domain/entities/access_mode.dart';
import 'package:cinerating/domain/usecases/auth/get_access_mode_usecase.dart';
import 'package:cinerating/domain/usecases/auth/login_usecase.dart';
import 'package:cinerating/domain/usecases/auth/logout_usecase.dart';
import 'package:cinerating/domain/usecases/auth/start_guest_session_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_current_user_usecase.dart';
import 'package:cinerating/presentation/controllers/login_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

/// Spec 001 (modo visitante): plano, seção 4.2, cenários U1–U7.
void main() {
  late FakeAuthRepository auth;
  late LoginController controller;

  setUp(() {
    auth = FakeAuthRepository();
    controller = LoginController(
      loginUseCase: LoginUseCase(auth),
      getCurrentUserUseCase: GetCurrentUserUseCase(auth),
      logoutUseCase: LogoutUseCase(auth),
      startGuestSessionUseCase: StartGuestSessionUseCase(auth),
      getAccessModeUseCase: GetAccessModeUseCase(auth),
    );
  });

  tearDown(() => controller.dispose());

  Future<bool> loginWith(String password) {
    controller.emailController.text = 'cinefilo';
    controller.passwordController.text = password;
    return controller.login();
  }

  group('checkExistingSession', () {
    // U1 — FR-012
    test('sem sessão: none, visitante e sem buscar o usuário', () async {
      await controller.checkExistingSession();

      expect(controller.accessMode, AccessMode.none);
      expect(controller.isGuest, isTrue);
      expect(controller.currentUser, isNull);
      expect(auth.calls, contains('getAccessMode'));
      expect(auth.calls, isNot(contains('getCurrentUser')));
      expect(controller.loadingDrawer, isFalse);
    });

    // U2 — FR-013
    test('sessão de conta: user e carrega o usuário', () async {
      auth.currentUser = Fixtures.user;

      await controller.checkExistingSession();

      expect(controller.accessMode, AccessMode.user);
      expect(controller.isGuest, isFalse);
      expect(controller.currentUser, Fixtures.user);
      expect(auth.calls, contains('getCurrentUser'));
    });

    // U2b — FR-005, FR-012
    test('sessão de convidado: guest e sem buscar o usuário', () async {
      auth.guestSession = true;

      await controller.checkExistingSession();

      expect(controller.accessMode, AccessMode.guest);
      expect(controller.isGuest, isTrue);
      expect(controller.currentUser, isNull);
      expect(auth.calls, isNot(contains('getCurrentUser')));
    });
  });

  group('continueAsGuest', () {
    // U3 — FR-002
    test('inicia a sessão de convidado e limpa os campos', () async {
      controller.emailController.text = 'cinefilo';
      controller.passwordController.text = 'qualquer';

      final ok = await controller.continueAsGuest();

      expect(ok, isTrue);
      expect(auth.calls, ['startGuestSession']);
      expect(controller.accessMode, AccessMode.guest);
      expect(controller.isGuest, isTrue);
      expect(controller.currentUser, isNull);
      expect(controller.emailController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    // U3b — FR-015
    test('falha: retorna false e continua sem acesso', () async {
      auth.failing.add('startGuestSession');

      final ok = await controller.continueAsGuest();

      expect(ok, isFalse);
      expect(controller.accessMode, AccessMode.none);
      expect(controller.isLoading, isFalse);
    });

    // U4 — US1
    test('notifica os listeners', () async {
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.continueAsGuest();

      expect(notified, greaterThan(0));
    });
  });

  group('login a partir do modo visitante', () {
    setUp(() => controller.continueAsGuest());

    // U5 — FR-009
    test('sucesso: user, deixa de ser visitante e guarda o usuário', () async {
      final ok = await loginWith('123456');

      expect(ok, isTrue);
      expect(controller.accessMode, AccessMode.user);
      expect(controller.isGuest, isFalse);
      expect(controller.currentUser, Fixtures.user);
    });

    // U6 — US3 cenário 3
    test('falha: continua visitante', () async {
      final ok = await loginWith('senha-errada');

      expect(ok, isFalse);
      expect(controller.accessMode, AccessMode.guest);
      expect(controller.isGuest, isTrue);
      expect(controller.currentUser, isNull);
    });
  });

  // U7 — FR-016
  test('logout volta a none', () async {
    await loginWith('123456');
    expect(controller.isGuest, isFalse);

    await controller.logout();

    expect(controller.accessMode, AccessMode.none);
    expect(controller.isGuest, isTrue);
    expect(controller.currentUser, isNull);
    expect(auth.calls, contains('logout'));
  });
}
