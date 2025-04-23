import 'package:flutter/material.dart';

Widget customButton(
  String text,
  bool? isIcon, {
  Color color = Colors.white,
  double? fontSize,
  EdgeInsetsGeometry? padding,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: color,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIcon == true)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.calendar_month_outlined,
                  color: Color(0XFF667085), size: fontSize),
            ),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w400,
              color:
                  color == Color(0XFF7DBD2C) ? Colors.white : Color(0XFF667085),
            ),
          ),
        ],
      ),
    ),
  );
}
