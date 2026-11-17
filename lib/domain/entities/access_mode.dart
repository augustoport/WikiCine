/// Como a pessoa está usando o app, conforme a sessão salva no aparelho.
enum AccessMode {
  /// Nenhuma sessão válida: a tela de login é exibida.
  none,

  /// Sessão de convidado do TMDB válida (modo visitante).
  guest,

  /// Sessão de conta do TMDB (usuário logado).
  user,
}
