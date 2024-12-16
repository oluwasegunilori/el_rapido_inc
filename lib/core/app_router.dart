import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:el_rapido_inc/dashboard/dashboard_page.dart';
import 'package:el_rapido_inc/auth/presentation/login/login_page.dart';
import 'package:el_rapido_inc/auth/presentation/signup/signup_page.dart';
import 'package:el_rapido_inc/auth/presentation/splashscreen/splashscreen.dart';
import 'package:el_rapido_inc/auth/presentation/verification/verification_page.dart';
import 'package:el_rapido_inc/main.dart';
import 'package:el_rapido_inc/merchantinventory/presentation/merchant_inventory_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
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
      builder: (context, state) => SignupPage(),
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
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MyHomePage(title: "title"),
    ),
    GoRoute(
      path: '/merchantinventory',
      builder: (context, state) {
        final String? merchantId = state.uri.queryParameters['merchant_id'];
        if (merchantId != null) {
          return MerchantInventoryPage(merchantId: merchantId);
        }
        return const DashboardPage();
      },
    ),
  ],
  redirect: (context, state) async {
    String? fullPath = state.fullPath;
    if (fullPath == "/" || fullPath == "/login" || fullPath == "/signup") {
      return null;
    }
    // Perform session check centrally
    final userSessionManager = getIt<UserSessionManager>();
    final isExpired = await userSessionManager.isSessionExpired();

    // If the session is expired, redirect to login
    if (isExpired && state.fullPath != '/login') {
      return '/login';
    }

    // If not expired, ensure the user is routed appropriately
    if (!isExpired && state.fullPath == '/') {
      return '/dashboard';
    }

    // No redirection needed
    return null;
  },
);
