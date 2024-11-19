import 'package:el_rapido_inc/auth/presentation/login/login_page.dart';
import 'package:el_rapido_inc/auth/presentation/splashscreen/splashscreen.dart';
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
  ],
);
