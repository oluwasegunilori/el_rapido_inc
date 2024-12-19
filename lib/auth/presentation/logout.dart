import 'package:el_rapido_inc/auth/presentation/auth_page_router.dart';
import 'package:el_rapido_inc/auth/repository/user_sessions_manager.dart';
import 'package:el_rapido_inc/core/di/deps_inject.dart';
import 'package:flutter/material.dart';

Widget buildLogoutButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.logout, color: Colors.red),
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                getIt<UserSessionManager>().clearSession();
                routeNeglect(context, route: "/login"); // Example navigation
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    },
    tooltip: 'Logout',
  );
}
