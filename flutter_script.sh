#!/bin/bash

# -----------------------------------------------------------------------------
# 🛠️ Flutter Clean Architecture Boilerplate Script
# -----------------------------------------------------------------------------
# Creating a Flutter app from scratch can be repetitive and time-consuming.
# This script automates the setup of a new Flutter project using Clean 
# Architecture and Test-Driven Development (TDD) practices. It helps you 
# focus more on feature development and less on boilerplate setup.
#
# What this script sets up:
# - ✅ Clean Architecture: Domain, Data, and Presentation layers
# - ✅ Bloc for scalable state management
# - ✅ Dependency injection via get_it
# - ✅ Dio for HTTP networking
# - ✅ Code generation with Freezed and JsonSerializable
# - ✅ Comprehensive testing setup (unit, bloc, and widget tests)
#
# 📦 Added Dependencies:
#   - flutter_bloc
#   - dartz
#   - get_it
#   - equatable
#   - freezed
#   - freezed_annotation
#   - json_serializable
#   - build_runner
#   - dio
#  
# 🧪 Testing Coverage:  
#   ✔️ Data Layer  
#     - ✅ `UserModel`: JSON serialization, copyWith, equality, symmetry  
#     - ✅ `AuthRepositoryImpl`: successful and failed login scenarios  
#  
#   ✔️ Domain Layer  
#     - ✅ `Login` UseCase: success, failure, and exception handling  
#  
#   ✔️ Presentation Layer  
#     - ✅ `AuthBloc`: event handling, state transitions, error responses  
#     - ✅ `LoginPage` Widget: form rendering, validation, interaction logic  
#
# 🧪 Dev Dependencies:
#   - mocktail
#   - bloc_test
#
# 🗂️ Project Structure:
#   This script generates a modular, feature-first folder structure under `lib/`
#   and mirrors it in the `test/` directory to enable clean and maintainable code.
#
# 📌 Usage:
#   1. Make the script executable (only once):
#        chmod +x script.sh
#
#   2. Run the script:
#        ./script.sh <flutter_app_name>
#
# 🧪 After setup, you’ll be prompted to:
#   1. Run all test cases
#   2. Launch the project on a simulator or device
#
# 💡 Platform Notes:
#   - Works out of the box on macOS and Linux
#   - For Windows, use Git Bash or WSL to run the script
#
# 🚀 This script saves hours of manual setup and enforces a scalable, 
# production-ready architecture from the start.
# -----------------------------------------------------------------------------

# Check project name
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME=$1

# # Create Flutter project
# flutter create $PROJECT_NAME
# cd $PROJECT_NAME || exit

# # Add required dependencies
# flutter pub add flutter_bloc dartz get_it equatable freezed freezed_annotation json_serializable build_runner dio
# flutter pub add -d mocktail bloc_test

# Create Flutter project
echo "📦 Creating Flutter project '$PROJECT_NAME'..."
if flutter create "$PROJECT_NAME" > /dev/null 2>&1; then
  echo "✅ Flutter project '$PROJECT_NAME' created."
else
  echo "❌ Failed to create Flutter project '$PROJECT_NAME'."
  exit 1
fi

# Change directory to the project
echo "🔄 Navigating to project directory '$PROJECT_NAME'..."
cd "$PROJECT_NAME" || { echo "❌ Failed to change directory to '$PROJECT_NAME'"; exit 1; }

echo "📦 Adding dependencies..."
if flutter pub add flutter_bloc dartz get_it equatable freezed freezed_annotation json_serializable build_runner dio > /dev/null 2>&1; then
  echo "✅ Main dependencies added."
else
  echo "❌ Failed to add main dependencies."
fi

if flutter pub add -d mocktail bloc_test > /dev/null 2>&1; then
  echo "✅ Dev dependencies added."
else
  echo "❌ Failed to add dev dependencies."
fi


# AUTH MODULE STRUCTURE
mkdir -p lib/features/auth/data/datasources
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories

mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/usecases

mkdir -p lib/features/auth/presentation/bloc
mkdir -p lib/features/auth/presentation/pages
mkdir -p lib/features/auth/presentation/widgets

mkdir -p lib/features/other

# TEST MODULE STRUCTURE
rm -rf test/widget_test.dart
mkdir -p test/features/auth/domain/usecases
mkdir -p test/features/auth/data/models
mkdir -p test/features/auth/data/repositories
mkdir -p test/features/auth/presentation/bloc
mkdir -p test/features/auth/presentation/pages
mkdir -p test/core
mkdir -p test/features/other

# Core structure
mkdir -p lib/core/error
mkdir -p lib/core/usecases
mkdir -p lib/core/di

# Add placeholder Dart files

## Core
cat <<EOF > lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
EOF

cat <<EOF > lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
EOF

## Domain Entity
cat <<EOF > lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;

  const User({required this.id, required this.email});

  const User.empty()
      : this(
          email: "_empty.email",
          id: "_empty_id",
        );

  @override
  List<Object?> get props => [id, email];
}
EOF

## Repository Interface
cat <<EOF > lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}
EOF

## Use Case
cat <<EOF > lib/features/auth/domain/usecases/login.dart
import 'package:dartz/dartz.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login extends UseCase<User, LoginEvent> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginEvent params) async {
    return await repository.login(params.email, params.password);
  }
}
EOF

## Bloc (basic)
cat <<EOF > lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login.dart';
import '../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;

  AuthBloc(this.login) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  void _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await login(event);
    result.fold(
      (failure) => emit(AuthFailure('Login failed')),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
EOF

## Login Page
cat <<'EOF' > lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      context.read<AuthBloc>().add(LoginEvent(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome ${state.user.email}!')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 32),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          key: const Key('loginButton'),
                          onPressed: _submitLogin,
                          child: const Text('Login'),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
EOF

# Auth Remote Data Source
cat <<EOF > lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSource implements AuthDataSource {
  final Dio client;

  AuthRemoteDataSource({required this.client});

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post('https://example.com/api/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Login failed');
    }
  }
}
EOF

# User Model
cat <<EOF > lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  UserModel copyWith(
    String? id,
    String? email,
  ) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  const UserModel.empty() : this(email: "_empty.email", id: "_empty.id");
}
EOF

# Auth Repository Implementation
cat <<EOF > lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
EOF

# Service Locator
cat <<EOF > lib/core/di/service_locator.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => AuthBloc(sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
      () => AuthRemoteDataSource(client: sl()));

  // External
  sl.registerLazySingleton(() => Dio());
}
EOF

# Test UserModel
cat <<EOF > test/features/auth/data/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:$PROJECT_NAME/features/auth/data/models/user_model.dart';
import 'package:$PROJECT_NAME/features/auth/domain/entities/user.dart';

void main() {
  // Dummy values
  const testId = '123';
  const testEmail = 'test@example.com';

  // Dummy model
  const tModel = UserModel(id: testId, email: testEmail);

  // Dummy JSON object
  final Map<String, dynamic> dummyJson = {
    'id': testId,
    'email': testEmail,
  };

  group('UserModel', () {
    // Test 1
    test('should be a subclass of [User]', () {
      expect(tModel, isA<User>());
    });

    // Test 2
    test('fromJson should return a valid model', () {
      final result = UserModel.fromJson(dummyJson);
      expect(result.id, testId);
      expect(result.email, testEmail);
    });

    // Test 3
    test('toJson should return a valid map', () {
      final result = tModel.toJson();
      expect(result, equals(dummyJson));
    });

    // Test 4
    test('copyWith should update fields when new values are provided', () {
      final updatedModel = tModel.copyWith('456', 'new@example.com');
      expect(updatedModel.id, '456');
      expect(updatedModel.email, 'new@example.com');
    });

    // Test 5
    test('copyWith should retain original values when null is provided', () {
      final updatedModel = tModel.copyWith(null, null);
      expect(updatedModel.id, tModel.id);
      expect(updatedModel.email, tModel.email);
    });

    // Test 6
    test('empty constructor should return a valid default instance', () {
      const emptyModel = UserModel.empty();
      expect(emptyModel.id, "_empty.id");
      expect(emptyModel.email, "_empty.email");
    });

    // Test 7
    test('toJson and fromJson should be symmetric', () {
      final json = tModel.toJson();
      final fromJsonModel = UserModel.fromJson(json);
      expect(fromJsonModel.id, tModel.id);
      expect(fromJsonModel.email, tModel.email);
    });

    // Test 8 (Optional: if equality is overridden in UserModel/User)
    test('value comparison should work correctly if overridden', () {
      final anotherModel = UserModel(id: testId, email: testEmail);
      expect(tModel, equals(anotherModel));
    });
  });
}
EOF

# Test Auth Repository
cat <<EOF > test/features/auth/data/repositories/auth_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:$PROJECT_NAME/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:$PROJECT_NAME/features/auth/data/models/user_model.dart';
import 'package:$PROJECT_NAME/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:$PROJECT_NAME/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:$PROJECT_NAME/core/error/failures.dart';

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
EOF

# Test Auth Login
cat <<EOF > test/features/auth/domain/usecases/login_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:$PROJECT_NAME/core/error/failures.dart';
import 'package:$PROJECT_NAME/features/auth/domain/entities/user.dart';
import 'package:$PROJECT_NAME/features/auth/domain/repositories/auth_repository.dart';
import 'package:$PROJECT_NAME/features/auth/domain/usecases/login.dart';
import 'package:$PROJECT_NAME/features/auth/presentation/bloc/auth_bloc.dart';

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
EOF

# Service Locator
cat <<EOF > test/features/auth/presentation/bloc/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:$PROJECT_NAME/features/auth/domain/entities/user.dart';
import 'package:$PROJECT_NAME/features/auth/domain/usecases/login.dart';
import 'package:$PROJECT_NAME/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:$PROJECT_NAME/core/error/failures.dart';

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
EOF

# Update main.dart to use DI
cat <<EOF > test/features/auth/presentation/pages/login_page_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:$PROJECT_NAME/features/auth/domain/entities/user.dart';
import 'package:$PROJECT_NAME/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:$PROJECT_NAME/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Mocking AuthBloc
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    // Test 1
    testWidgets('renders all form elements', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    // Test 2
    testWidgets('shows validation error when fields are empty', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);
    });

    // Test 3
    testWidgets('dispatches LoginEvent when valid form is submitted', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), '123456');

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      verify(() => mockAuthBloc.add(LoginEvent('test@example.com', '123456'))).called(1);
    });

    // Test 4
    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsNothing);
    });

    // Test 5
    testWidgets('shows success snackbar on AuthSuccess', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          AuthLoading(),
          AuthSuccess(User(id: '1', email: 'test@example.com')),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // AuthLoading
      await tester.pump(const Duration(milliseconds: 100)); // Allow transition
      await tester.pump(); // AuthSuccess

      expect(find.text('Welcome test@example.com!'), findsOneWidget);
    });

    // Test 6
    testWidgets('shows error snackbar on AuthFailure', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          AuthInitial(),
          AuthLoading(),
          AuthFailure('Login failed'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // AuthLoading
      await tester.pump(const Duration(milliseconds: 100)); // Allow transition
      await tester.pump(); // AuthFailure

      expect(find.text('Login failed'), findsOneWidget);
    });
  });
}
EOF

# Update main.dart to use DI
cat <<EOF > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => di.sl<AuthBloc>(),
        child: LoginPage(),
      ),
    );
  }
}
EOF

# Print directory structure
echo ""
echo "📁 Project structure created:"

echo "lib/"
echo "├── core/"
echo "│   ├── di/                    └── service_locator.dart"
echo "│   ├── error/                 └── failures.dart"
echo "│   └── usecases/              └── usecase.dart"
echo "├── features/"
echo "│   └── auth/"
echo "│       ├── data/"
echo "│       │   ├── datasources/   └── auth_remote_data_source.dart"
echo "│       │   ├── models/        └── user_model.dart"
echo "│       │   └── repositories/  └── auth_repository_impl.dart"
echo "│       ├── domain/"
echo "│       │   ├── entities/      └── user.dart"
echo "│       │   ├── repositories/  └── auth_repository.dart"
echo "│       │   └── usecases/      └── login.dart"
echo "│       └── presentation/"
echo "│           ├── bloc/          └── auth_bloc.dart"
echo "│           ├── pages/         └── login_page.dart"
echo "│           └── widgets/"
echo "└── main.dart"

echo ""
echo "test/"
echo "└── features/"
echo "    └── auth/"
echo "        ├── data/"
echo "        │   └── models/        └── user_model_test.dart"
echo "        ├── domain/"
echo "        │   └── usecases/      └── login_test.dart"
echo "        ├── repositories/      └── auth_repository_impl_test.dart"
echo "        └── presentation/"
echo "            └── bloc/          └── auth_bloc_test.dart"
echo "            └── pages/         └── login_page_test.dart"

echo ""
echo "✅ Basic Project Structure has been Created Successfully. Project is now ready to run."


# Ask user if they want to run tests
read -p "📦 Do you want to run the test cases? (y/n): " run_tests
if [[ "$run_tests" == "y" || "$run_tests" == "Y" ]]; then
  flutter test
fi

# Ask user if they want to run the app
read -p "🚀 Do you want to run the project now? (y/n): " run_app
if [[ "$run_app" == "y" || "$run_app" == "Y" ]]; then
  flutter run
fi
