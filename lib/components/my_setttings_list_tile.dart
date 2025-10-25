import 'package:flutter/material.dart';

class MySetttingsListTile extends StatelessWidget {
  final String title;
  final Widget action;
  final Color color;
  final Color textColor;

  const MySetttingsListTile({
    super.key,
    required this.title,
    required this.action,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 25, right: 25, top: 10),
      padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // text
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),

          // action
          action,
        ],
      ),
    );
  }
}
