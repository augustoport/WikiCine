import 'package:cinerating/presentation/bloc/profile/profile_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../presentation/bloc/home/home_cubit.dart';
import '../presentation/bloc/movie_detail/movie_cubit.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/login_controller.dart';
import '../data/datasources/data/auth_data.dart';
import '../data/datasources/implementations/auth_implementation.dart';
import '../data/datasources/data/movie_data.dart';
import '../data/datasources/implementations/movie_implementation.dart';
import '../data/datasources/data/tv_data.dart';
import '../data/datasources/implementations/tv_implementation.dart';
import '../data/repositories/auth_api.dart';
import '../data/repositories/movie_api.dart';
import '../data/repositories/tv_api.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/movie_repository.dart';
import '../domain/repositories/tv_repository.dart';
import '../domain/usecases/user/get_current_user_usecase.dart';
import '../domain/usecases/movies/get_movie_crew_usecase.dart';
import '../domain/usecases/movies/get_movie_details_usecase.dart';
import '../domain/usecases/movies/get_movies_usecase.dart';
import '../domain/usecases/tv_show/get_tv_show_crew_usecase.dart';
import '../domain/usecases/tv_show/get_tv_show_details_usecase.dart';
import '../domain/usecases/tv_show/get_tv_shows_usecase.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/movies/search_movies_usecase.dart';
import '../domain/usecases/tv_show/search_tv_shows_usecase.dart';
import 'shared/themes/app_colors.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<AppColors>(AppColors());

  // Datasources
  getIt.registerLazySingleton<AuthData>(() => AuthImplementation());

  getIt.registerLazySingleton<MovieData>(() => MovieImplementation());

  getIt.registerLazySingleton<TvData>(() => TvImplementation());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthApi(getIt<AuthData>(), const FlutterSecureStorage()),
  );

  getIt.registerLazySingleton<MovieRepository>(
    () => MovieApi(getIt<MovieData>()),
  );

  getIt.registerLazySingleton<TvRepository>(
    () => TvRepositoryImpl(remoteDataSource: getIt<TvData>()),
  );

  // Use Cases
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<GetMoviesUseCase>(
    () => GetMoviesUseCase(getIt<MovieRepository>()),
  );

  getIt.registerFactory<SearchMoviesUseCase>(
    () => SearchMoviesUseCase(getIt<MovieRepository>()),
  );

  getIt.registerFactory<GetTvShowsUseCase>(
    () => GetTvShowsUseCase(getIt<TvRepository>()),
  );

  getIt.registerFactory<SearchTvShowsUseCase>(
    () => SearchTvShowsUseCase(getIt<TvRepository>()),
  );

  getIt.registerFactory<GetMovieCrewUseCase>(
    () => GetMovieCrewUseCase(getIt<MovieRepository>()),
  );

  getIt.registerFactory<GetMovieDetailsUseCase>(
    () => GetMovieDetailsUseCase(getIt<MovieRepository>()),
  );

  getIt.registerFactory<GetTvShowCrewUseCase>(
    () => GetTvShowCrewUseCase(getIt<TvRepository>()),
  );

  getIt.registerFactory<GetTvShowDetailsUseCase>(
    () => GetTvShowDetailsUseCase(getIt<TvRepository>()),
  );

  // Controllers
  getIt.registerLazySingleton<LoginController>(() => LoginController());

  getIt.registerFactory<HomeController>(() => HomeController());

  // Cubits
  getIt.registerFactory<HomeCubit>(() => HomeCubit());

  getIt.registerFactory<ProfileCubit>(() => ProfileCubit());

  getIt.registerFactory<MovieCubit>(() => MovieCubit());
}
