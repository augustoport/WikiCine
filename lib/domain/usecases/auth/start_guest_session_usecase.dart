import '../../repositories/auth_repository.dart';

/// Inicia o modo visitante: cria uma sessão de convidado no TMDB ou
/// reaproveita uma ainda válida.
class StartGuestSessionUseCase {
  final AuthRepository authRepository;

  StartGuestSessionUseCase(this.authRepository);

  Future<void> call() => authRepository.startGuestSession();
}
