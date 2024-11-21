import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget routeWidget(
    {required String text,
    required String route,
    required BuildContext context}) {
  return Center(
      child: GestureDetector(
    onTap: () {
      Router.neglect(
          context,
              () => context.go(route));
    },
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).primaryColor, // Primary color text
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ));
}

/**
 * Removes previous destinations
 */
void routeNeglect(BuildContext context, {required String route}) {
  Router.neglect(
      context,
          () => context.go(route));
}