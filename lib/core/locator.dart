import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../data/datasources/data/auth_data.dart';
import '../data/datasources/data/movie_data.dart';
import '../data/datasources/data/tv_data.dart';
import '../data/datasources/data/user_data.dart';
import '../data/datasources/implementations/auth_implementation.dart';
import '../data/datasources/implementations/movie_implementation.dart';
import '../data/datasources/implementations/tv_implementation.dart';
import '../data/datasources/implementations/user_implementation.dart';
import '../data/repositories/auth_api.dart';
import '../data/repositories/movie_api.dart';
import '../data/repositories/tv_api.dart';
import '../data/repositories/user_api.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/movie_repository.dart';
import '../domain/repositories/tv_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/movies/get_movie_crew_usecase.dart';
import '../domain/usecases/movies/get_movie_details_usecase.dart';
import '../domain/usecases/movies/get_movies_usecase.dart';
import '../domain/usecases/movies/search_movies_usecase.dart';
import '../domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import '../domain/usecases/tv_show/get_tv_show_details_usecase.dart';
import '../domain/usecases/tv_show/get_tv_shows_usecase.dart';
import '../domain/usecases/tv_show/search_tv_shows_usecase.dart';
import '../domain/usecases/user/get_current_user_usecase.dart';
import '../domain/usecases/user/get_user_favorites_usecase.dart';
import '../presentation/bloc/home/home_cubit.dart';
import '../presentation/bloc/movie_detail/movie_cubit.dart';
import '../presentation/bloc/profile/profile_cubit.dart';
import '../presentation/bloc/serie_detail/serie_cubit.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/login_controller.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Infra
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Datasources
  getIt.registerLazySingleton<AuthData>(
    () => AuthImplementation(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<MovieData>(() => MovieImplementation());
  getIt.registerLazySingleton<TvData>(() => TvImplementation());
  getIt.registerLazySingleton<UserData>(
    () => UserImplementation(getIt<FlutterSecureStorage>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthApi(getIt<AuthData>(), getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieApi(getIt<MovieData>()),
  );
  getIt.registerLazySingleton<TvRepository>(
    () => TvRepositoryImpl(remoteDataSource: getIt<TvData>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserApi(getIt<UserData>()),
  );

  // Use Cases
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetUserFavoritesUseCase(getIt<UserRepository>()));
  getIt.registerFactory(() => GetMoviesUseCase(getIt<MovieRepository>()));
  getIt.registerFactory(() => SearchMoviesUseCase(getIt<MovieRepository>()));
  getIt.registerFactory(() => GetMovieDetailsUseCase(getIt<MovieRepository>()));
  getIt.registerFactory(() => GetMovieCrewUseCase(getIt<MovieRepository>()));
  getIt.registerFactory(() => GetTvShowsUseCase(getIt<TvRepository>()));
  getIt.registerFactory(() => SearchTvShowsUseCase(getIt<TvRepository>()));
  getIt.registerFactory(() => GetTvShowDetailsUseCase(getIt<TvRepository>()));
  getIt.registerFactory(() => GetTvShowCrewUseCase(getIt<TvRepository>()));

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
}
