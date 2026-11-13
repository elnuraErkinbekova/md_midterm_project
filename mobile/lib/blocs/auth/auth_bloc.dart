import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await _repository.restoreSession();
      emit(user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await _repository.login(event.email.trim(), event.password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: errorMessage(e)));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final user = await _repository.register(event.name.trim(), event.email.trim(), event.password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: errorMessage(e)));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
