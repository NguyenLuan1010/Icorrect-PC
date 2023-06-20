import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_themes.dart';

class GradientBorderPainter extends CustomPainter {
  double width, height;
  GradientBorderPainter(this.width, this.height);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppThemes.colors.purple,
          AppThemes.colors.purple,
          AppThemes.colors.purple,
          Colors.white
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, height), const Radius.circular(5)));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
