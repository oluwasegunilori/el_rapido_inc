import 'package:bloc_test/bloc_test.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_bloc.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_event.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_state.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/app_router.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'splashscreen_page_test.mocks.dart';

// Generate a mock UserSessionManager
@GenerateMocks([UserSessionManager])
void main() {
  group('SplashScreen Tests', () {
    late MockUserSessionManager mockUserSessionManager;
    late MockLoginBloc mockLoginBloc;

    setUp(() {
      mockUserSessionManager = MockUserSessionManager();
      mockLoginBloc = MockLoginBloc();
      getIt.registerSingleton<UserSessionManager>(
        mockUserSessionManager,
      );
      getIt.registerFactory<LoginBloc>(() => mockLoginBloc);
    });

    tearDown(() {
      GetIt.instance.reset();
      // Ensure any lingering widget states are cleared.
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Navigates to /login if session is expired', (tester) async {
      // Arrange
      when(mockUserSessionManager.isSessionExpired())
          .thenAnswer((_) async => true);

      whenListen(mockLoginBloc, Stream.fromIterable([LoginInitial()]),
          initialState: LoginInitial());

      // Override the userSessionManager instance in SplashScreen
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: appRrouter,
      ));

      verify(mockUserSessionManager.isSessionExpired()).called(1);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      // Assert Login Navigation
      expect(find.text("Login"), findsAny);

    });

    testWidgets('Navigates to /dashboard if session is not expired',
        (tester) async {
      //    
      appRrouter.go("/");
      // Arrange
      when(mockUserSessionManager.isSessionExpired())
          .thenAnswer((_) async => false);

      // Override the userSessionManager instance in SplashScreen
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: appRrouter,
      ));

      verify(mockUserSessionManager.isSessionExpired()).called(1);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      // Assert Login Navigation
      expect(find.text("Inventories"), findsAny);
    });
  });
}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}
