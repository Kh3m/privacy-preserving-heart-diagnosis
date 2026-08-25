import 'package:flutter/material.dart';
import '../../../constant.dart';

class ChooseDate extends StatelessWidget {
  final String week;
  final String date;
  final bool check;

  const ChooseDate({
    super.key,
    required this.week,
    required this.date,
    this.check = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          week,
          style: const TextStyle(
            color: mTitleTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: check ? mBarColor : Colors.transparent,
            border: Border.all(
                color: check ? mBarColor : mTitleTextColor, width: 0.5),
            borderRadius: BorderRadius.circular(36),
          ),
          child: Text(
            date,
            style: TextStyle(
              color: check ? Colors.white : mTitleTextColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
