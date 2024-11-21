import 'package:el_rapido_inc/auth/presentation/login/login_page.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_page.dart';
import 'package:el_rapido_inc/auth/presentation/splashscreen/splashscreen.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRrouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) {
        final String? token = state.uri.queryParameters['token'];
        return SignupPage(token: token);
      },
    ),
    GoRoute(
      path: '/signupverification',
      builder: (context, state) {
        final String? token = state.uri.queryParameters['token'];
        return VerificationPage(token: token);
      },
    ),
  ],
);
