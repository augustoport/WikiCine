import 'package:bloc/bloc.dart';

import '../../../domain/usecases/auth/is_logged_in_usecase.dart';
import '../../../domain/usecases/user/get_user_favorites_usecase.dart';
import 'profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit({
    required GetUserFavoritesUseCase getUserFavoritesUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
  }) : _getUserFavoritesUseCase = getUserFavoritesUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       super(ProfileInitial());

  final GetUserFavoritesUseCase _getUserFavoritesUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;

  /// Sem sessão de conta (visitante ou nenhuma) → [ProfileRestricted], sem
  /// consultar dados de conta (spec 001, FR-010 e FR-012).
  Future<void> initProfile() async {
    if (!await _isLoggedInUseCase()) {
      emit(ProfileRestricted());
      return;
    }

    emit(ProfileLoading());
    try {
      final favorites = await _getUserFavoritesUseCase();
      emit(ProfileSuccess(favorites: favorites, watchlist: []));
    } catch (e) {
      emit(ProfileError());
    }
  }
}
