import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final bool needRepaint;
  final Offset center;
  final double radius;


  CirclePainter({
    required this.needRepaint,
    required this.center,
    required this.radius,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool? hitTest(Offset position) {
    // Calculate the distance between the position and the center of the circle
    final distance = (position - center).distance;


    // Check if the distance is within the radius of the circle
    if (distance <= radius) {
      return true;
    } else {
      return false;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => needRepaint;
}