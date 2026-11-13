part of 'auth_bloc.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, error];
}
