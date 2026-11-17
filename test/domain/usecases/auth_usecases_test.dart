import 'package:cinerating/domain/entities/access_mode.dart';
import 'package:cinerating/domain/usecases/auth/get_access_mode_usecase.dart';
import 'package:cinerating/domain/usecases/auth/is_logged_in_usecase.dart';
import 'package:cinerating/domain/usecases/auth/login_usecase.dart';
import 'package:cinerating/domain/usecases/auth/logout_usecase.dart';
import 'package:cinerating/domain/usecases/auth/start_guest_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('LoginUseCase', () {
    test('repassa credenciais ao repositório e retorna o usuário', () async {
      final useCase = LoginUseCase(repository);

      final user = await useCase(username: 'cinefilo', password: '123456');

      expect(user, same(Fixtures.user));
      expect(repository.calls, ['login:cinefilo']);
    });

    test('propaga a exceção quando as credenciais são inválidas', () {
      final useCase = LoginUseCase(repository);

      expect(
        () => useCase(username: 'cinefilo', password: 'errada'),
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('LogoutUseCase', () {
    test('delega ao repositório', () async {
      repository.currentUser = Fixtures.user;

      await LogoutUseCase(repository)();

      expect(repository.calls, ['logout']);
      expect(repository.currentUser, isNull);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('logout');

      expect(
        LogoutUseCase(repository).call,
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('IsLoggedInUseCase', () {
    late FakeAuthRepository repository;

    setUp(() => repository = FakeAuthRepository());

    test('true quando há sessão', () async {
      repository.currentUser = Fixtures.user;

      expect(await IsLoggedInUseCase(repository)(), isTrue);
      expect(repository.calls, ['isLoggedIn']);
    });

    test('false para visitante (sem sessão)', () async {
      expect(await IsLoggedInUseCase(repository)(), isFalse);
    });

    test('false com sessão de convidado (não é conta)', () async {
      repository.guestSession = true;

      expect(await IsLoggedInUseCase(repository)(), isFalse);
    });
  });

  /// Spec 001 (modo visitante): plano, seção 4.2, cenários D1–D3.
  group('StartGuestSessionUseCase', () {
    // D1 — FR-002
    test('delega ao repositório', () async {
      await StartGuestSessionUseCase(repository)();

      expect(repository.calls, ['startGuestSession']);
      expect(repository.guestSession, isTrue);
    });

    // D2 — FR-015
    test('propaga falha do repositório', () {
      repository.failing.add('startGuestSession');

      expect(
        StartGuestSessionUseCase(repository).call,
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  // D3 — FR-005, FR-013
  group('GetAccessModeUseCase', () {
    test('none sem sessão', () async {
      expect(await GetAccessModeUseCase(repository)(), AccessMode.none);
      expect(repository.calls, ['getAccessMode']);
    });

    test('guest com sessão de convidado', () async {
      repository.guestSession = true;

      expect(await GetAccessModeUseCase(repository)(), AccessMode.guest);
    });

    test('user com sessão de conta, mesmo havendo convidado', () async {
      repository.guestSession = true;
      repository.currentUser = Fixtures.user;

      expect(await GetAccessModeUseCase(repository)(), AccessMode.user);
    });
  });
}
