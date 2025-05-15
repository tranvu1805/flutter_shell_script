import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sample_app/core/error/failures.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sample_app/features/auth/domain/usecases/login.dart';
import 'package:sample_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late Login usecase;
  late AuthRepository mockAuthRepo;
  const mockUser = User.empty();
  final email = mockUser.email;
  const password = 'protected';
  final loginEvent = LoginEvent(mockUser.email, "protected");

  setUpAll(
    () {
      mockAuthRepo = MockAuthRepo();
      usecase = Login(mockAuthRepo);
    },
  );

  test(
    'should call AuthRepository.login and return User on success',
    () async {
      // Arrange
      when(() => mockAuthRepo.login(any(), any()))
          .thenAnswer((_) async => const Right(mockUser));

      // Act
      final result = await usecase(loginEvent);

      // Assert
      expect(result, equals(const Right(mockUser)));
      verify(() => mockAuthRepo.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return [ServerFailure] on unsuccessful login',
    () async {
      // Arrange
      when(() => mockAuthRepo.login(any(), any()))
          .thenAnswer((_) async => Left<ServerFailure, User>(ServerFailure()));

      // Act
      final result = await usecase(loginEvent);

      // Assert
      expect(result, equals(Left<ServerFailure, User>(ServerFailure())));
      verify(() => mockAuthRepo.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );

  test(
    'should return [Failure] if login throws an unexpected exception',
    () async {
      // Arrange
      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('Unexpected Error'));

      // Act & Assert
      expect(
        () => usecase(loginEvent),
        throwsA(isA<Exception>()),
      );
      verify(() => mockAuthRepo.login(email, password)).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    },
  );
}
