import 'package:flutter/material.dart';

/// Small hand-drawn-style spark accent (3 short radiating strokes) used
/// flanking the logo and primary CTA buttons.
class SparkAccent extends StatelessWidget {
  const SparkAccent({super.key, this.size = 20, this.color = const Color(0xFFFF5722)});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparkPainter(color: color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width * 0.35, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width, size.height * 0.55), Offset(size.width * 0.7, size.height * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.color != color;
}
