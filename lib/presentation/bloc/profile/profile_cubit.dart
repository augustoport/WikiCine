import 'package:bloc/bloc.dart';

import '../../../domain/usecases/user/get_user_favorites_usecase.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit({required GetUserFavoritesUseCase getUserFavoritesUseCase})
    : _getUserFavoritesUseCase = getUserFavoritesUseCase,
      super(ProfileInitial());

  final GetUserFavoritesUseCase _getUserFavoritesUseCase;

  Future<void> initProfile() async {
    emit(ProfileLoading());
    try {
      final favorites = await _getUserFavoritesUseCase();
      emit(ProfileSuccess(favorites: favorites, watchlist: []));
    } catch (e) {
      emit(ProfileError());
    }
  }
}
