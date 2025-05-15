import 'package:dartz/dartz.dart';
import 'package:sample_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sample_app/features/auth/data/models/user_model.dart';
import 'package:sample_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sample_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sample_app/core/error/failures.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthDataSource mockAuthRemoteDataSource;
  late AuthRepository authRepository;
  const password = 'protected';
  const UserModel mockUserModel = UserModel.empty();

  setUpAll(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    authRepository = AuthRepositoryImpl(remoteDataSource: mockAuthRemoteDataSource);
  });

  group("Login", () {
    // Test 1: Successful login
    test(
      'should call the [AuthRemoteDataSource.login] and return [UserModel] on success',
      () async {
        // Arrange
        when(() => mockAuthRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => mockUserModel);

        // Act
        final result = await authRepository.login(mockUserModel.email, password);

        // Assert
        expect(result, equals(Right(mockUserModel)));
        verify(() => mockAuthRemoteDataSource.login(mockUserModel.email, password)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

    // Test 2: Server failure
    test(
      'should return [ServerFailure] when the login call fails',
      () async {
        // Arrange
        when(() => mockAuthRemoteDataSource.login(any(), any()))
            .thenThrow(Exception());

        // Act
        final result = await authRepository.login(mockUserModel.email, password);

        // Assert
        expect(result, equals(Left(ServerFailure())));
        verify(() => mockAuthRemoteDataSource.login(mockUserModel.email, password)).called(1);
        verifyNoMoreInteractions(mockAuthRemoteDataSource);
      },
    );

  });
}
