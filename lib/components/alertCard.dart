import 'package:flutter/material.dart';

enum NotificationType { success, warning, error }

Widget buildNotificationCard(String message, NotificationType type) {
  Color bgColor;
  Icon icon;

  switch (type) {
    case NotificationType.success:
      bgColor = Colors.green.shade100;
      icon = Icon(Icons.check_circle, color: Colors.green, size: 32);
      break;
    case NotificationType.warning:
      bgColor = Colors.orange.shade100;
      icon = Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32);
      break;
    case NotificationType.error:
      bgColor = Colors.red.shade100;
      icon = Icon(Icons.cancel_rounded, color: Colors.red, size: 32);
      break;
  }

  return Card(
    color: bgColor,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          icon,
          SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(fontSize: 16))),
        ],
      ),
    ),
  );
}
