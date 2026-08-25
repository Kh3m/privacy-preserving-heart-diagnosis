import 'package:flutter/material.dart';

import '../../../models/category.dart';
import '../../../utils/hex_color.dart';

class CategoryCell extends StatelessWidget {
  final Category category;
  final Function onCatTap;

  const CategoryCell({
    super.key,
    required this.category,
    required this.onCatTap,
  });

  /// **********************************************
  /// LIFE CYCLE METHODS
  /// **********************************************

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 100,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: HexColor('#EDFDFA'),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: () => onCatTap(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    category.icon,
                    size: 24,
                    color: HexColor('#00C6AD'),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: HexColor('#010101'),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                height: 30,
                width: 75,
                decoration: BoxDecoration(
                    color: HexColor('#E1F7F4'),
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(10))),
              ),
              Positioned(
                left: 16,
                child: Text(
                  'Specialist',
                  style: TextStyle(
                    color: HexColor('#696969'),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
