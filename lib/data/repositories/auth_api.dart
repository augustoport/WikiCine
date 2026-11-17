import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/shared/storage_keys.dart';
import '../../domain/entities/access_mode.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/data/auth_data.dart';

class AuthApi implements AuthRepository {
  final AuthData authData;
  final FlutterSecureStorage storage;

  /// Relógio usado para conferir a validade da sessão de convidado.
  final DateTime Function() _now;

  AuthApi(this.authData, this.storage, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await authData.login(username: username, password: password);
    await _clearGuestSession();
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    final sessionId = await storage.read(key: StorageKeys.sessionId);
    if (sessionId == null) return null;

    try {
      return await authData.getAccountDetails(sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await storage.read(key: StorageKeys.sessionId) != null;
  }

  @override
  Future<void> logout() async {
    await storage.delete(key: StorageKeys.sessionId);
    await storage.delete(key: StorageKeys.accountId);
    await _clearGuestSession();
  }

  @override
  Future<void> startGuestSession() async {
    if (await _hasValidGuestSession()) return;

    final session = await authData.createGuestSession();
    await storage.write(key: StorageKeys.guestSessionId, value: session.id);
    await storage.write(
      key: StorageKeys.guestSessionExpiresAt,
      value: session.expiresAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<AccessMode> getAccessMode() async {
    if (await isLoggedIn()) return AccessMode.user;
    if (await _hasValidGuestSession()) return AccessMode.guest;
    return AccessMode.none;
  }

  /// Sessão de convidado salva e dentro da validade. Expirada ou ilegível é
  /// descartada.
  Future<bool> _hasValidGuestSession() async {
    final id = await storage.read(key: StorageKeys.guestSessionId);
    final expiresAt = DateTime.tryParse(
      await storage.read(key: StorageKeys.guestSessionExpiresAt) ?? '',
    );

    if (id != null && expiresAt != null && _now().isBefore(expiresAt)) {
      return true;
    }
    if (id != null || expiresAt != null) await _clearGuestSession();
    return false;
  }

  Future<void> _clearGuestSession() async {
    await storage.delete(key: StorageKeys.guestSessionId);
    await storage.delete(key: StorageKeys.guestSessionExpiresAt);
  }
}
