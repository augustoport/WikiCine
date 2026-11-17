/// Resposta de `GET /authentication/guest_session/new`.
class GuestSessionModel {
  final String id;

  /// Validade informada pelo TMDB, em UTC.
  final DateTime expiresAt;

  GuestSessionModel({required this.id, required this.expiresAt});

  /// O TMDB envia `expires_at` como `"2026-11-17 23:35:17 UTC"`, formato que
  /// `DateTime.parse` não aceita; o sufixo ` UTC` vira `Z`.
  factory GuestSessionModel.fromJson(Map<String, dynamic> json) {
    final raw = json['expires_at'].toString().replaceFirst(' UTC', 'Z');
    return GuestSessionModel(
      id: json['guest_session_id'].toString(),
      expiresAt: DateTime.parse(raw).toUtc(),
    );
  }
}
