import 'package:bloc/bloc.dart';
import 'package:cinerating/presentation/bloc/profile/profile_states.dart';

import '../../../core/locator.dart';
import '../../../domain/usecases/user/get_user_favorites_usecases.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitial());

  final _favorites = getIt<GetUserFavoritesUsecases>();

  Future<void> initProfile() async {
    emit(ProfileLoading());
    try {
      final favorites = await _favorites();
      emit(ProfileSuccess(favorites: favorites, watchlist: []));
    } catch (e) {
      emit(ProfileError());
    }
  }
}
