import 'package:el_rapido_inc/auth/presentation/dashboard/dashboard_page.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_page.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_page.dart';
import 'package:el_rapido_inc/auth/presentation/splashscreen/splashscreen.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_page.dart';
import 'package:el_rapido_inc/main.dart';
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
        return SignupPage();
      },
    ),
    GoRoute(
      path: '/signupverification',
      builder: (context, state) {
        final String? token = state.uri.queryParameters['token'];
        return VerificationPage(token: token);
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        return const DashboardPage();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const MyHomePage(title: "title");
      },
    ),
  ],
);
