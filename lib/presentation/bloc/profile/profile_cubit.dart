import 'package:bloc/bloc.dart';
import 'package:cinerating/presentation/bloc/profile/profile_states.dart';

import '../../../core/locator.dart';
import '../../../domain/repositories/movie_repository.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitial());

  final movieApi = getIt<MovieRepository>();

  Future<void> initProfile() async {
    emit(ProfileLoading());
    try {
      final favorites = await movieApi.getFavoriteMovies();
      emit(ProfileSuccess(favorites: favorites, watchlist: []));
    } catch (e) {
      emit(ProfileError());
    }
  }
}
