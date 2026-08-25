import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  final bool hasDisease;

  CircleProgress(
    {
      required this.hasDisease
    }
  );

  @override
  void paint(Canvas canvas, Size size) {
      // TODO: implement paint
      Paint circle = Paint()
      ..strokeWidth = 5
      ..color = !hasDisease ? Colors.grey : Colors.redAccent
      ..style = PaintingStyle.stroke;

      Offset center = Offset(
        size.width / 2, 
        size.height / 2
      ); // center of device

      double radius = 150;
      canvas.drawCircle(center, radius, circle);
    }
  
    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
  
}