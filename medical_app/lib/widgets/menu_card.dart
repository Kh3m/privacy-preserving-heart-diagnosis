import 'package:flutter/material.dart';
import '../../constant.dart';

class MenuCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback press;

  const MenuCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: <Widget>[
          Image.asset(
            imageUrl,
            width: 135,
            height: 135,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: TextStyle(
              color: mTitleTextColor,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
