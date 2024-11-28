import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:el_rapido_inc/dashboard/dashboard_page.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_page.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_state.dart';
import 'package:el_rapido_inc/auth/presentation/splashscreen/splashscreen.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../splashscreen/splashscreen_page_test.dart';

void main() {
  group("Login Page Test", () {
    late MockLoginBloc mockLoginBloc;

    setUp(() {
      mockLoginBloc = MockLoginBloc();
      getIt.registerFactory<LoginBloc>(() => mockLoginBloc);
    });

    tearDown(() {
      getIt.reset();
    });

    testWidgets('LoginPage renders and interacts correctly',
        (WidgetTester tester) async {
      // Arrange
      final streamController = StreamController<LoginState>();
      whenListen(mockLoginBloc, streamController.stream,
          initialState: LoginInitial());

      // whenListen(
      //   mockLoginBloc,
      //   Stream.fromIterable([
      //     LoginInitial(),
      //     LoginLoading(),
      //     LoginFailure("Invalid credentials"),
      //     LoginNotActivated(error: "Account not activated"),
      //     LoginSuccess(),
      //   ]),
      //   initialState: LoginInitial(),
      // );

      // Pump the app
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => DashboardPage(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => LoginPage(),
            ),
          ],
        ),
      ));

      // Assert UI elements
      expect(find.text('ElRapido'), findsOneWidget);
      expect(find.text('Login'), findsAtLeast(1));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Act: Fill in the form
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com'); // Email
      await tester.enterText(
          find.byType(TextFormField).last, 'password123'); // Password

      // Trigger login
      await tester.tap(find.byKey(const ValueKey('loginButton')));

      // Assert: Loading state
      streamController.add(LoginLoading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance the bloc state to LoginFailure
      streamController.add(LoginFailure("Invalid credentials"));
      await tester.pump();
      expect(find.text('Invalid credentials'), findsOneWidget);

      // Simulate account not activated
      streamController.add(LoginNotActivated(error: "Account not activated"));
      await tester.pump();
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Account not activated'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));

      // Simulate successful login
      await tester.pump();
      streamController.add(LoginSuccess());

      await tester.pumpAndSettle();
      // Verify navigation to /dashboard
      expect(find.text("Inventories"), findsAny);
    });
  });
}
