import 'package:cinerating/domain/usecases/auth/login_usecase.dart';
import 'package:cinerating/domain/usecases/auth/logout_usecase.dart';
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

      expect(LogoutUseCase(repository).call, throwsA(isA<FakeRepositoryException>()));
    });
  });
}
