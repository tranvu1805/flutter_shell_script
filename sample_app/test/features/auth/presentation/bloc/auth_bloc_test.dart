import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/domain/usecases/login.dart';
import 'package:sample_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sample_app/core/error/failures.dart';

// Mock class
class MockLogin extends Mock implements Login {}

void main() {
  late AuthBloc authBloc;
  late MockLogin mockLogin;

  const tPassword = 'protected';
  const tUser = User.empty();
  final loginEvent = LoginEvent(tUser.email, tPassword);

  setUp(() {
    mockLogin = MockLogin();
    authBloc = AuthBloc(mockLogin);
    registerFallbackValue(loginEvent);
  });

  // Test 1: Initial login State
  test('initial state should be [AuthInitial]', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  // Test 2: Successful login
  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSuccess] when login is successful',
    build: () {
      when(() => mockLogin(any())).thenAnswer((_) async => const Right(tUser));
      return authBloc;
    },
    act: (bloc) => bloc.add(LoginEvent(tUser.email, tPassword)),
    expect: () => [
      AuthLoading(),
      AuthSuccess(tUser),
    ],
    verify: (_) {
      verify(() => mockLogin(LoginEvent(tUser.email, tPassword))).called(1);
      verifyNoMoreInteractions(mockLogin);
    },
  );

  // Test 3: Failed login
  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthFailure] when login fails',
    build: () {
      when(() => mockLogin(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      return authBloc;
    },
    act: (bloc) => bloc.add(LoginEvent(tUser.email, tPassword)),
    expect: () => [
      AuthLoading(),
      isA<AuthFailure>().having((s) => s.message, 'message', 'Login failed'),
    ],
    verify: (_) {
      verify(() => mockLogin(LoginEvent(tUser.email, tPassword))).called(1);
      verifyNoMoreInteractions(mockLogin);
    },
  );
}
