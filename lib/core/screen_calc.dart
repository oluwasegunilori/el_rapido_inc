import 'package:flutter/material.dart';

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 800; // Adjust threshold if needed
}

DateTimeRange getCurrentMonthRange() {
  DateTime now = DateTime.now();
  DateTime firstDay = DateTime(now.year, now.month, 1);
  DateTime lastDay = DateTime(now.year, now.month + 1, 0);

  return DateTimeRange(start: firstDay, end: lastDay);
}

DateTimeRange getLastTwoMonthsRange() {
  DateTime now = DateTime.now();
  DateTime firstDay = DateTime(now.year, now.month - 2, 1);
  DateTime lastDay =
      DateTime(now.year, now.month + 1, 0); // Last day of the previous month

  return DateTimeRange(start: firstDay, end: lastDay);
}

DateTimeRange getThisAndLastMonthRange() {
  DateTime now = DateTime.now();
  DateTime firstDay =
      DateTime(now.year, now.month - 1, 1); // First day of last month
  DateTime lastDay =
      DateTime(now.year, now.month + 1, 0); // Last day of current month

  return DateTimeRange(start: firstDay, end: lastDay);
}
