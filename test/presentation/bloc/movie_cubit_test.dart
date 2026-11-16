import 'package:cinerating/domain/usecases/auth/is_logged_in_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_crew_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_details_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_user_favorites_usecase.dart';
import 'package:cinerating/domain/usecases/user/set_movie_favorite_usecase.dart';
import 'package:cinerating/presentation/bloc/movie_detail/movie_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeMovieRepository movies;
  late FakeUserRepository user;
  late MovieCubit cubit;

  setUp(() {
    auth = FakeAuthRepository()..currentUser = Fixtures.user;
    movies = FakeMovieRepository();
    user = FakeUserRepository()..favorites = [Fixtures.movieA];
    cubit = MovieCubit(
      getMovieDetailsUseCase: GetMovieDetailsUseCase(movies),
      getMovieCrewUseCase: GetMovieCrewUseCase(movies),
      getUserFavoritesUseCase: GetUserFavoritesUseCase(user),
      setMovieFavoriteUseCase: SetMovieFavoriteUseCase(user),
      isLoggedInUseCase: IsLoggedInUseCase(auth),
    );
  });

  tearDown(() => cubit.close());

  group('getMovieDetails', () {
    test('logado: canFavorite e isFavorite a partir da lista', () async {
      await cubit.getMovieDetails('1');

      expect((cubit.state as MovieSuccess).canFavorite, isTrue);
      expect(cubit.isFavorite.value, isTrue);
    });

    test('visitante: canFavorite false e não consulta favoritos', () async {
      auth.currentUser = null;

      await cubit.getMovieDetails('1');

      expect((cubit.state as MovieSuccess).canFavorite, isFalse);
      expect(cubit.isFavorite.value, isFalse);
      expect(user.calls, isEmpty);
    });
  });

  group('toggleFavorite', () {
    test('adiciona: atualiza isFavorite sem emitir novo estado', () async {
      await cubit.getMovieDetails('2');
      final stateBefore = cubit.state;
      final emitted = <Object>[];
      final sub = cubit.stream.listen(emitted.add);

      final result = await cubit.toggleFavorite();
      await sub.cancel();

      expect(result, FavoriteResult.added);
      expect(cubit.isFavorite.value, isTrue);
      expect(user.calls.last, 'setMovieFavorite:2:true');
      expect(emitted, isEmpty, reason: 'não deve passar por MovieLoading');
      expect(cubit.state, same(stateBefore));
    });

    test('remove quando já é favorito', () async {
      await cubit.getMovieDetails('1');

      expect(await cubit.toggleFavorite(), FavoriteResult.removed);
      expect(cubit.isFavorite.value, isFalse);
      expect(user.calls.last, 'setMovieFavorite:1:false');
    });

    test('falha ao adicionar mantém isFavorite e retorna addFailed', () async {
      user.failing.add('setMovieFavorite');
      await cubit.getMovieDetails('2');

      expect(await cubit.toggleFavorite(), FavoriteResult.addFailed);
      expect(cubit.isFavorite.value, isFalse);
    });

    test('falha ao remover mantém isFavorite e retorna removeFailed', () async {
      user.failing.add('setMovieFavorite');
      await cubit.getMovieDetails('1');

      expect(await cubit.toggleFavorite(), FavoriteResult.removeFailed);
      expect(cubit.isFavorite.value, isTrue);
    });

    test('visitante: não faz nada', () async {
      auth.currentUser = null;
      await cubit.getMovieDetails('2');

      expect(await cubit.toggleFavorite(), isNull);
      expect(user.calls, isEmpty);
    });

    test('ignora toque repetido enquanto a atualização está em andamento', () async {
      await cubit.getMovieDetails('2');
      user.delay = const Duration(milliseconds: 20);

      final first = cubit.toggleFavorite();
      final second = await cubit.toggleFavorite();

      expect(second, isNull);
      expect(await first, FavoriteResult.added);
      expect(user.calls.where((c) => c.startsWith('setMovieFavorite')), hasLength(1));
    });

    test('antes de carregar o filme não faz nada', () async {
      expect(await cubit.toggleFavorite(), isNull);
    });
  });
}
