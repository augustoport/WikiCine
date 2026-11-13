import 'package:cinerating/core/locator.dart';
import 'package:cinerating/domain/usecases/auth/login_usecase.dart';
import 'package:cinerating/domain/usecases/auth/logout_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_crew_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movie_details_usecase.dart';
import 'package:cinerating/domain/usecases/movies/get_movies_usecase.dart';
import 'package:cinerating/domain/usecases/movies/search_movies_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_show_details_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/get_tv_shows_usecase.dart';
import 'package:cinerating/domain/usecases/tv_show/search_tv_shows_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_current_user_usecase.dart';
import 'package:cinerating/domain/usecases/user/get_user_favorites_usecase.dart';
import 'package:cinerating/presentation/bloc/home/home_cubit.dart';
import 'package:cinerating/presentation/bloc/movie_detail/movie_cubit.dart';
import 'package:cinerating/presentation/bloc/profile/profile_cubit.dart';
import 'package:cinerating/presentation/bloc/serie_detail/serie_cubit.dart';
import 'package:cinerating/presentation/controllers/home_controller.dart';
import 'package:cinerating/presentation/controllers/login_controller.dart';

import 'fakes.dart';

/// Repositórios falsos registrados no `getIt` para um teste.
class TestDeps {
  final auth = FakeAuthRepository();
  final movies = FakeMovieRepository();
  final tv = FakeTvRepository();
  final user = FakeUserRepository();
}

/// Espelha `setupLocator()` trocando datasources/repositórios por fakes.
///
/// As páginas resolvem cubits e controllers via `getIt`, então o grafo
/// acima dos repositórios é o mesmo da aplicação real.
Future<TestDeps> setupTestLocator() async {
  await getIt.reset();
  final deps = TestDeps();

  // Use Cases
  getIt.registerFactory(() => LoginUseCase(deps.auth));
  getIt.registerFactory(() => LogoutUseCase(deps.auth));
  getIt.registerFactory(() => GetCurrentUserUseCase(deps.auth));
  getIt.registerFactory(() => GetUserFavoritesUseCase(deps.user));
  getIt.registerFactory(() => GetMoviesUseCase(deps.movies));
  getIt.registerFactory(() => SearchMoviesUseCase(deps.movies));
  getIt.registerFactory(() => GetMovieDetailsUseCase(deps.movies));
  getIt.registerFactory(() => GetMovieCrewUseCase(deps.movies));
  getIt.registerFactory(() => GetTvShowsUseCase(deps.tv));
  getIt.registerFactory(() => SearchTvShowsUseCase(deps.tv));
  getIt.registerFactory(() => GetTvShowDetailsUseCase(deps.tv));
  getIt.registerFactory(() => GetTvShowCrewUseCase(deps.tv));

  // Controllers
  getIt.registerLazySingleton<LoginController>(
    () => LoginController(
      loginUseCase: getIt<LoginUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
  getIt.registerFactory<HomeController>(() => HomeController());

  // Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getMoviesUseCase: getIt<GetMoviesUseCase>(),
      searchMoviesUseCase: getIt<SearchMoviesUseCase>(),
      getTvShowsUseCase: getIt<GetTvShowsUseCase>(),
      searchTvShowsUseCase: getIt<SearchTvShowsUseCase>(),
    ),
  );
  getIt.registerFactory<MovieCubit>(
    () => MovieCubit(
      getMovieDetailsUseCase: getIt<GetMovieDetailsUseCase>(),
      getMovieCrewUseCase: getIt<GetMovieCrewUseCase>(),
      getUserFavoritesUseCase: getIt<GetUserFavoritesUseCase>(),
    ),
  );
  getIt.registerFactory<SerieCubit>(
    () => SerieCubit(
      getTvShowDetailsUseCase: getIt<GetTvShowDetailsUseCase>(),
      getTvShowCrewUseCase: getIt<GetTvShowCrewUseCase>(),
    ),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getUserFavoritesUseCase: getIt<GetUserFavoritesUseCase>()),
  );

  return deps;
}
