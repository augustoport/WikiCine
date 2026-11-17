import 'package:cinerating/data/models/guest_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Spec 001 (modo visitante): plano, seção 4.2, cenário M1.
void main() {
  // M1 — FR-004. Formato real do TMDB, conferido em 2026-11-16.
  test('fromJson lê o id e converte expires_at "... UTC" para UTC', () {
    final model = GuestSessionModel.fromJson({
      'success': true,
      'guest_session_id': 'guest-abc',
      'expires_at': '2026-11-17 23:35:17 UTC',
    });

    expect(model.id, 'guest-abc');
    expect(model.expiresAt, DateTime.utc(2026, 11, 17, 23, 35, 17));
    expect(model.expiresAt.isUtc, isTrue);
  });
}
