import '../../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<void> call() {
    return authRepository.logout();
  }
}
