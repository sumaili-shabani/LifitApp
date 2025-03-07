import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, String type) {
  final color =
      {
        'success': Colors.green,
        'warning': Colors.orange,
        'danger': Colors.red,
      }[type] ??
      Colors.blue; // Default color if type is unknown

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            type == 'success'
                ? Icons.check_circle
                : type == 'warning'
                ? Icons.warning
                : Icons.error,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
