import 'package:bloc_test/bloc_test.dart';
import 'package:firstflutterproject/blocs/auth/auth_bloc.dart';
import 'package:firstflutterproject/models/user.dart';
import 'package:firstflutterproject/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  const user = User(id: 1, name: 'Test', email: 't@x.com');

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<AuthBloc, AuthState>(
    'AuthStarted: authenticated when a saved session is valid',
    setUp: () => when(() => repository.restoreSession()).thenAnswer((_) async => user),
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState(status: AuthStatus.authenticated, user: user)],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthStarted: unauthenticated when there is no saved session',
    setUp: () => when(() => repository.restoreSession()).thenAnswer((_) async => null),
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthLoginRequested: loading, then authenticated',
    setUp: () => when(() => repository.login('t@x.com', 'secret1')).thenAnswer((_) async => user),
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested(' t@x.com ', 'secret1')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthLoginRequested: loading, then unauthenticated with an error',
    setUp: () => when(() => repository.login(any(), any())).thenThrow(Exception('wrong password')),
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested('t@x.com', 'bad')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.unauthenticated)
          .having((s) => s.error, 'error', isNotNull),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthRegisterRequested: loading, then authenticated',
    setUp: () => when(() => repository.register('Test', 't@x.com', 'secret1'))
        .thenAnswer((_) async => user),
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthRegisterRequested('Test', 't@x.com', 'secret1')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthLogoutRequested: logs out and becomes unauthenticated',
    setUp: () => when(() => repository.logout()).thenAnswer((_) async {}),
    build: () => AuthBloc(repository),
    seed: () => const AuthState(status: AuthStatus.authenticated, user: user),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    verify: (_) => verify(() => repository.logout()).called(1),
  );
}
