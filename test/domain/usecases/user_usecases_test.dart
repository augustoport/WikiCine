import 'package:cinerating/domain/usecases/user/get_current_user_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_user_favorites_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  group('GetCurrentUserUseCase', () {
    late FakeAuthRepository repository;

    setUp(() => repository = FakeAuthRepository());

    test('retorna o usuário da sessão existente', () async {
      repository.currentUser = Fixtures.user;

      final user = await GetCurrentUserUseCase(repository)();

      expect(user, same(Fixtures.user));
      expect(repository.calls, ['getCurrentUser']);
    });

    test('retorna null quando não há sessão', () async {
      expect(await GetCurrentUserUseCase(repository)(), isNull);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getCurrentUser');

      expect(
        GetCurrentUserUseCase(repository).call,
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });

  group('GetUserFavoritesUseCase', () {
    late FakeUserRepository repository;

    setUp(() => repository = FakeUserRepository());

    test('retorna os filmes favoritos do usuário', () async {
      repository.favorites = Fixtures.movies;

      final favorites = await GetUserFavoritesUseCase(repository)();

      expect(favorites, Fixtures.movies);
      expect(repository.calls, ['getUserMovieFavorites']);
    });

    test('retorna lista vazia quando não há favoritos', () async {
      repository.favorites = [];

      expect(await GetUserFavoritesUseCase(repository)(), isEmpty);
    });

    test('propaga falha do repositório', () {
      repository.failing.add('getUserMovieFavorites');

      expect(
        GetUserFavoritesUseCase(repository).call,
        throwsA(isA<FakeRepositoryException>()),
      );
    });
  });
}
