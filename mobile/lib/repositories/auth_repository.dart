import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../data/auth_api.dart';
import '../models/user.dart';

class AuthRepository {
  static const _tokenKey = 'auth_token';

  final AuthApi _api;
  final ApiClient _client;
  AuthRepository(this._api, this._client);

  Future<User> login(String email, String password) async {
    final result = await _api.login(email, password);
    await _saveToken(result.token);
    return result.user;
  }

  Future<User> register(String name, String email, String password) async {
    final result = await _api.register(name, email, password);
    await _saveToken(result.token);
    return result.user;
  }

  Future<User?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    _client.token = token;
    try {
      return await _api.me();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    _client.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    _client.token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}
