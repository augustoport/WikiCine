import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<User> call({required String username, required String password}) {
    return authRepository.login(username: username, password: password);
  }
}
