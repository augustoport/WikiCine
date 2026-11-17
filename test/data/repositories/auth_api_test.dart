import 'package:cinerating/core/shared/storage_keys.dart';
import 'package:cinerating/data/datasources/data/auth_data.dart';
import 'package:cinerating/data/models/guest_session_model.dart';
import 'package:cinerating/data/repositories/auth_api.dart';
import 'package:cinerating/domain/entities/access_mode.dart';
import 'package:cinerating/domain/entities/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

/// `AuthData` falso: registra chamadas e devolve dados fixos.
class FakeAuthData implements AuthData {
  final List<String> calls = [];

  GuestSessionModel guestSession = GuestSessionModel(
    id: 'guest-novo',
    expiresAt: DateTime.utc(2026, 11, 17, 12),
  );

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    calls.add('login');
    return Fixtures.user;
  }

  @override
  Future<User> getAccountDetails(String sessionId) async {
    calls.add('getAccountDetails');
    return Fixtures.user;
  }

  @override
  Future<GuestSessionModel> createGuestSession() async {
    calls.add('createGuestSession');
    return guestSession;
  }
}

/// Spec 001 (modo visitante): plano, seção 4.2, cenários A1–A10.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// "Agora" fixo para os testes de validade.
  final now = DateTime.utc(2026, 11, 16, 12);
  final future = now.add(const Duration(hours: 1)).toIso8601String();
  final past = now.subtract(const Duration(minutes: 1)).toIso8601String();

  late FakeAuthData data;
  late FlutterSecureStorage storage;
  late AuthApi api;

  void build(Map<String, String> saved) {
    FlutterSecureStorage.setMockInitialValues(Map.of(saved));
    data = FakeAuthData();
    storage = const FlutterSecureStorage();
    api = AuthApi(data, storage, now: () => now);
  }

  Future<Map<String, String>> saved() => storage.readAll();

  const guestKeys = [
    StorageKeys.guestSessionId,
    StorageKeys.guestSessionExpiresAt,
  ];

  group('getAccessMode', () {
    // A1 — FR-001
    test('nada salvo → none', () async {
      build({});

      expect(await api.getAccessMode(), AccessMode.none);
    });

    // A2 — FR-013 e edge "ambas as sessões"
    test('sessão de conta → user, mesmo havendo convidado', () async {
      build({
        StorageKeys.sessionId: 'session-123',
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: future,
      });

      expect(await api.getAccessMode(), AccessMode.user);
    });

    // A3 — FR-005
    test('convidado com validade futura → guest', () async {
      build({
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: future,
      });

      expect(await api.getAccessMode(), AccessMode.guest);
    });

    // A4 — FR-014
    test('convidado expirado → none e chaves de convidado apagadas', () async {
      build({
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: past,
      });

      expect(await api.getAccessMode(), AccessMode.none);
      expect(await saved(), isEmpty);
    });

    // A4 (variação) — validade ilegível é tratada como expirada
    test('validade ilegível → none e chaves apagadas', () async {
      build({
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: 'lixo',
      });

      expect(await api.getAccessMode(), AccessMode.none);
      expect(await saved(), isEmpty);
    });
  });

  group('startGuestSession', () {
    // A5 — FR-002, FR-004
    test('sem sessão: cria e grava id e validade', () async {
      build({});

      await api.startGuestSession();

      expect(data.calls, ['createGuestSession']);
      final values = await saved();
      expect(values[StorageKeys.guestSessionId], 'guest-novo');
      expect(
        DateTime.parse(values[StorageKeys.guestSessionExpiresAt]!),
        DateTime.utc(2026, 11, 17, 12),
      );
      expect(await api.getAccessMode(), AccessMode.guest);
    });

    // A6 — US3-3
    test('com convidado válido: reaproveita, sem nova chamada', () async {
      build({
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: future,
      });

      await api.startGuestSession();

      expect(data.calls, isEmpty);
      expect((await saved())[StorageKeys.guestSessionId], 'guest-1');
    });

    // A7 — FR-014
    test('com convidado expirado: cria outra', () async {
      build({
        StorageKeys.guestSessionId: 'guest-1',
        StorageKeys.guestSessionExpiresAt: past,
      });

      await api.startGuestSession();

      expect(data.calls, ['createGuestSession']);
      expect((await saved())[StorageKeys.guestSessionId], 'guest-novo');
    });
  });

  // A8 — FR-009
  test('login com sucesso apaga a sessão de convidado', () async {
    build({
      StorageKeys.guestSessionId: 'guest-1',
      StorageKeys.guestSessionExpiresAt: future,
    });

    final user = await api.login(username: 'cinefilo', password: '123456');

    expect(user, same(Fixtures.user));
    final keys = (await saved()).keys;
    for (final key in guestKeys) {
      expect(keys, isNot(contains(key)));
    }
  });

  // A9 — FR-016
  test('logout apaga conta e convidado', () async {
    build({
      StorageKeys.sessionId: 'session-123',
      StorageKeys.accountId: '42',
      StorageKeys.guestSessionId: 'guest-1',
      StorageKeys.guestSessionExpiresAt: future,
    });

    await api.logout();

    expect(await saved(), isEmpty);
    expect(await api.getAccessMode(), AccessMode.none);
  });

  // A10 — FR-006
  test('isLoggedIn é false só com convidado', () async {
    build({
      StorageKeys.guestSessionId: 'guest-1',
      StorageKeys.guestSessionExpiresAt: future,
    });

    expect(await api.isLoggedIn(), isFalse);
  });
}
