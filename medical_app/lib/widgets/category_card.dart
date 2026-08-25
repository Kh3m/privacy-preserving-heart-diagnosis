import 'package:flutter/material.dart';

import '../models/category.dart';
import '../utils/hex_color.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onCatTap;

  const CategoryCard({
    super.key, 
    required this.category, 
    required this.onCatTap
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onCatTap,
        hoverColor: Colors.red,
        child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color: Colors.deepPurple[100],
          color: HexColor('#EDFDFA'),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              category.icon,
              size: 24,
              color: HexColor('#00C6AD'),
            ),
            const SizedBox(width: 10,),
            Text(category.title,
            style: TextStyle(
                color: HexColor('#010101'),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                ),
            ),
          ],
        ),
      ),
    );
  }
}