import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final userSessionManager = UserSessionManagerImpl();

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
     context.pushReplacement('/login');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
