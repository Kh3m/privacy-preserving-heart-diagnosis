import 'package:flutter/material.dart';

import '../../../constant.dart';

class DisplayText extends StatelessWidget {
  final String text;
  final bool check;

  const DisplayText({
    super.key,
    required this.text,
    required this.check,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: check ? mBarColor : Colors.transparent,
        border:
            Border.all(color: check ? mBarColor : mTitleTextColor, width: 0.5),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 12, color: check ? Colors.white : mTitleTextColor),
      ),
    );
  }
}
