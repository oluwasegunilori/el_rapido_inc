import 'package:el_rapido_inc/auth/presentation/auth_page_router.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart' as sl;
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final userSessionManager = sl.getIt<UserSessionManager>();

  @override
  Widget build(BuildContext context) {
    _checkSession(context);
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void _checkSession(BuildContext context) async {
    final isExpired = await userSessionManager.isSessionExpired();
    if (isExpired) {
      routeNeglect(context, route: "/login");
    } else {
      routeNeglect(context, route: "/dashboard");
    }
  }
}
