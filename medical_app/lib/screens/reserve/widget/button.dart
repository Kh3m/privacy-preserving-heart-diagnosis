import 'package:flutter/material.dart';

import '../../../constant.dart';

class Button extends StatelessWidget {
  final String text;
  VoidCallback? onPressed;

  Button({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: mBarColor,
          border: Border.all(color: mBarColor, width: 0.5),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
