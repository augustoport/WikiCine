import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});
  Future<User?> getCurrentUser();
  Future<void> logout();

  /// `true` se há sessão de usuário salva no aparelho (sem chamada de rede).
  /// Visitante (guest) ou usuário deslogado → `false`.
  Future<bool> isLoggedIn();
}
