import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepository;

  GetCurrentUserUseCase(this.authRepository);

  Future<User?> call() {
    return authRepository.getCurrentUser();
  }
}
