import '../../entities/access_mode.dart';
import '../../repositories/auth_repository.dart';

/// Modo de acesso atual (conta, visitante ou nenhum), sem chamada de rede.
class GetAccessModeUseCase {
  final AuthRepository authRepository;

  GetAccessModeUseCase(this.authRepository);

  Future<AccessMode> call() => authRepository.getAccessMode();
}
