import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Completed':
      return Colors.green.shade400;
    case 'Pending':
      return Colors.yellow.shade700;
    case 'In Progress':
      return Colors.blue.shade400;
    case 'Rejected':
      return Colors.red.shade400;
    case 'OnHold':
      return const Color.fromARGB(255, 33, 238, 241);
    default:
      return Colors.grey;
  }
}

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return Colors.red;
    case 'Medium':
      return Colors.orange;
    case 'Low':
      return Colors.green;
    default:
      return Colors.black;
  }
}

Widget buildDetailRow(
    String label, String value, double labelFontSize, double contentFontSize) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: labelFontSize,
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: contentFontSize,
          ),
        ),
      ),
    ],
  );
}

// Helper method to format DateTime
String formatDateTime(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}
