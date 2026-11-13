import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/user.dart';
import '../../../core/shared/env.dart';
import '../../../core/shared/storage_keys.dart';
import '../../models/user_model.dart';
import '../data/auth_data.dart';

class AuthImplementation implements AuthData {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthImplementation(this._storage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: Environment.production.baseUrl,
          headers: {
            'Authorization': 'Bearer ${Environment.production.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final requestToken = await createRequestToken();

    final validatedToken = await validateLogin(
      username: username,
      password: password,
      requestToken: requestToken,
    );

    final sessionId = await createSession(validatedToken);

    await _storage.write(key: StorageKeys.sessionId, value: sessionId);

    return await getAccountDetails(sessionId);
  }

  @override
  Future<User> getAccountDetails(String sessionId) async {
    final response = await _dio.get(
      '/account',
      queryParameters: {'session_id': sessionId},
    );

    final accountId = response.data['id']?.toString() ?? '';
    await _storage.write(key: StorageKeys.accountId, value: accountId);

    return UserModel.fromJson(response.data, sessionId);
  }

  Future<String> createRequestToken() async {
    final response = await _dio.get(
      '/authentication/token/new',
      queryParameters: {'api_key': Environment.production.apiKey},
    );
    return response.data['request_token']?.toString() ?? '';
  }

  Future<String> validateLogin({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    try {
      final response = await _dio.post(
        '/authentication/token/validate_with_login',
        queryParameters: {'api_key': Environment.production.apiKey},
        data: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
      );
      return response.data['request_token']?.toString() ?? '';
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createSession(String requestToken) async {
    final response = await _dio.post(
      '/authentication/session/new',
      queryParameters: {'api_key': Environment.production.apiKey},
      data: {'request_token': requestToken},
    );
    return response.data['session_id']?.toString() ?? '';
  }
}
