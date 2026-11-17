/// Chaves usadas no `FlutterSecureStorage`.
abstract final class StorageKeys {
  static const sessionId = 'tmdb_session_id';
  static const accountId = 'account_id';

  /// Sessão de convidado do TMDB (modo visitante) e sua validade (ISO 8601).
  static const guestSessionId = 'tmdb_guest_session_id';
  static const guestSessionExpiresAt = 'tmdb_guest_session_expires_at';
}
