import 'package:cinerating/domain/usecases/auth/is_logged_in_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_user_favorites_usecase.dart';
import 'package:cinerating/presentation/bloc/profile/profile_cubit.dart';
import 'package:cinerating/presentation/bloc/profile/profile_states.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fixtures.dart';

/// Spec 001 (modo visitante): plano, seção 4.2, cenários U8–U11.
void main() {
  late FakeAuthRepository auth;
  late FakeUserRepository user;
  late ProfileCubit cubit;

  setUp(() {
    auth = FakeAuthRepository()..currentUser = Fixtures.user;
    user = FakeUserRepository()..favorites = Fixtures.movies;
    cubit = ProfileCubit(
      getUserFavoritesUseCase: GetUserFavoritesUseCase(user),
      isLoggedInUseCase: IsLoggedInUseCase(auth),
    );
  });

  tearDown(() => cubit.close());

  Future<List<ProfileStates>> initAndCollect() async {
    final emitted = <ProfileStates>[];
    final sub = cubit.stream.listen(emitted.add);
    await cubit.initProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    return emitted;
  }

  // U8 — regressão
  test('com sessão: Loading → Success com os favoritos', () async {
    final states = await initAndCollect();

    expect(states, hasLength(2));
    expect(states[0], isA<ProfileLoading>());
    expect(states[1], isA<ProfileSuccess>());
    expect((states[1] as ProfileSuccess).favorites, Fixtures.movies);
    expect(user.calls, ['getUserMovieFavorites']);
  });

  // U9 — FR-010, FR-012
  test('sem sessão: Restricted e não consulta favoritos', () async {
    auth.currentUser = null;

    await cubit.initProfile();

    expect(cubit.state, isA<ProfileRestricted>());
    expect(user.calls, isEmpty);
  });

  // U11 — FR-006, FR-010: convidado não é conta.
  test('só sessão de convidado: Restricted', () async {
    auth.currentUser = null;
    auth.guestSession = true;

    await cubit.initProfile();

    expect(cubit.state, isA<ProfileRestricted>());
    expect(user.calls, isEmpty);
  });

  // U10 — regressão
  test('com sessão e favoritos falhando: Error', () async {
    user.failing.add('getUserMovieFavorites');

    await cubit.initProfile();

    expect(cubit.state, isA<ProfileError>());
  });
}
