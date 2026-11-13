import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/shared/storage_keys.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/data/auth_data.dart';

class AuthApi implements AuthRepository {
  final AuthData authData;
  final FlutterSecureStorage storage;

  AuthApi(this.authData, this.storage);

  @override
  Future<User> login({required String username, required String password}) {
    return authData.login(username: username, password: password);
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
  Future<void> logout() async {
    await storage.delete(key: StorageKeys.sessionId);
    await storage.delete(key: StorageKeys.accountId);
  }
}
