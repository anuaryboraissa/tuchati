import 'package:flutter/material.dart';

class BottomIconWidget extends StatelessWidget {
  const BottomIconWidget({
    Key? key,
    required this.title,
    required this.iconName,
    this.iconColor,
  }) : super(key: key);
  final String title;
  final String iconName;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset(
              iconName,
              width: 16,
              height: 16,
              color: iconColor,
            ),
          ),

          Text(
            title,
            style: TextStyle(color: iconColor),
          ),
        ],
      ),
    );
  }
}
