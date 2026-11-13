import '../core/api_client.dart';
import '../models/user.dart';

class AuthResult {
  final String token;
  final User user;
  const AuthResult(this.token, this.user);
}

abstract class AuthApi {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String name, String email, String password);
  Future<User> me();
}

class AuthApiImpl implements AuthApi {
  final ApiClient _client;
  AuthApiImpl(this._client);

  AuthResult _parse(dynamic data) {
    final map = data as Map<String, dynamic>;
    return AuthResult(map['token'] as String, User.fromJson(map['user'] as Map<String, dynamic>));
  }

  @override
  Future<AuthResult> login(String email, String password) async =>
      _parse((await _client.dio.post('/auth/login', data: {'email': email, 'password': password})).data);

  @override
  Future<AuthResult> register(String name, String email, String password) async => _parse(
        (await _client.dio.post('/auth/register', data: {'name': name, 'email': email, 'password': password})).data,
      );

  @override
  Future<User> me() async => User.fromJson((await _client.dio.get('/auth/me')).data as Map<String, dynamic>);
}
