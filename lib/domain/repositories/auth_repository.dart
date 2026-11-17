import '../entities/access_mode.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});
  Future<User?> getCurrentUser();

  /// Descarta a sessão de conta e a sessão de convidado.
  Future<void> logout();

  /// `true` se há sessão de **conta** salva no aparelho (sem chamada de rede).
  /// Visitante (sessão de convidado) ou sem sessão → `false`.
  Future<bool> isLoggedIn();

  /// Cria uma sessão de convidado no TMDB e a guarda com sua validade.
  /// Se já existe uma válida, reaproveita sem nova chamada.
  Future<void> startGuestSession();

  /// Modo de acesso pela sessão salva: conta → [AccessMode.user]; convidado
  /// válido → [AccessMode.guest]; senão [AccessMode.none]. Uma sessão de
  /// convidado expirada é descartada.
  Future<AccessMode> getAccessMode();
}
