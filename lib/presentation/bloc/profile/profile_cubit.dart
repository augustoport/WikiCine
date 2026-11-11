import 'package:bloc/bloc.dart';
import 'package:cinerating/presentation/bloc/profile/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitial());

  void initProfile() {
    emit(ProfileLoading());
    
  }
}
