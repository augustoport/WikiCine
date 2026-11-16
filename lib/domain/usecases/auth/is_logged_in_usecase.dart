import '../../repositories/auth_repository.dart';

/// Indica se há um usuário logado (sessão salva). Visitante → `false`.
class IsLoggedInUseCase {
  final AuthRepository authRepository;

  IsLoggedInUseCase(this.authRepository);

  Future<bool> call() => authRepository.isLoggedIn();
}
