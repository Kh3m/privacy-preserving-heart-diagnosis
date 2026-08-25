import 'package:flutter/material.dart';
import '../../../constant.dart';

class ChooseTime extends StatelessWidget {
  final String time;
  final bool check;

  const ChooseTime({
    super.key,
    required this.time,
    this.check = false,
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
        time,
        style: TextStyle(
            fontSize: 12, color: check ? Colors.white : mTitleTextColor),
      ),
    );
  }
}
