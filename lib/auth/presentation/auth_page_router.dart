import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget routeWidget(
    {required String text,
    required String route,
    required BuildContext context}) {
  return Center(
      child: GestureDetector(
    onTap: () {
      context.pushReplacement(route); // Navigate to the second screen
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
