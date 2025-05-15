import 'package:bloc_test/bloc_test.dart';
import 'package:sample_app/features/auth/domain/entities/user.dart';
import 'package:sample_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sample_app/features/auth/presentation/pages/login_page.dart';
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
