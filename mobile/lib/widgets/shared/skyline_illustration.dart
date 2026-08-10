import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Brand illustration used on auth screens and the dashboard: a sepia
/// arch containing a simplified minaret skyline, an orange location pin,
/// and a small hand-drawn-style dashed flourish.
class SkylineIllustration extends StatelessWidget {
  const SkylineIllustration({super.key, this.size = 220, this.pinColor = const Color(0xFFFF5722)});

  final double size;
  final Color pinColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.05,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BlobClipper(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEDDFC5), Color(0xFFDCC7A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _SkylinePainter())),
          Positioned(
            left: size * 0.10,
            top: size * 0.40,
            child: Icon(Icons.location_on, color: pinColor, size: size * 0.20),
          ),
          Positioned(
            left: -size * 0.06,
            bottom: size * 0.02,
            child: CustomPaint(
              size: Size(size * 0.32, size * 0.18),
              painter: _DashedSquigglePainter(color: pinColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height * 0.22, size.width, size.height * 0.78),
          const Radius.circular(28),
        ),
      );
    final dome = Path()..addOval(Rect.fromLTWH(-size.width * 0.04, 0, size.width * 1.08, size.height * 0.62));
    return Path.combine(PathOperation.union, base, dome);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SkylinePainter extends CustomPainter {
  static const _lineColor = Color(0xFF8B6F47);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.62;
    final baseY = size.height * 0.92;

    // Base
    final baseRect = Rect.fromCenter(center: Offset(cx, baseY - size.height * 0.02), width: size.width * 0.22, height: size.height * 0.05);
    canvas.drawRect(baseRect, stroke);

    // Shaft
    final shaftTop = baseY - size.height * 0.45;
    final shaftRect = Rect.fromLTRB(cx - size.width * 0.045, shaftTop, cx + size.width * 0.045, baseRect.top);
    canvas.drawRect(shaftRect, stroke);

    // Balcony band
    final balconyY = shaftTop + size.height * 0.10;
    canvas.drawLine(Offset(cx - size.width * 0.075, balconyY), Offset(cx + size.width * 0.075, balconyY), stroke);

    // Spire
    final spirePath = Path()
      ..moveTo(shaftRect.left, shaftTop)
      ..lineTo(cx, shaftTop - size.height * 0.14)
      ..lineTo(shaftRect.right, shaftTop);
    canvas.drawPath(spirePath, stroke);

    // Finial
    canvas.drawCircle(Offset(cx, shaftTop - size.height * 0.17), size.width * 0.012, stroke);
    canvas.drawLine(
      Offset(cx, shaftTop - size.height * 0.145),
      Offset(cx, shaftTop - size.height * 0.185),
      stroke,
    );

    // Small side roofline for depth
    final roofPath = Path()
      ..moveTo(baseRect.left - size.width * 0.06, baseRect.top)
      ..lineTo(baseRect.left, baseY - size.height * 0.09)
      ..lineTo(baseRect.left, baseRect.top);
    canvas.drawPath(roofPath, stroke);

    // Birds
    _drawBird(canvas, stroke, Offset(size.width * 0.28, size.height * 0.30), size.width * 0.045);
    _drawBird(canvas, stroke, Offset(size.width * 0.40, size.height * 0.20), size.width * 0.035);
    _drawBird(canvas, stroke, Offset(size.width * 0.20, size.height * 0.42), size.width * 0.03);
  }

  void _drawBird(Canvas canvas, Paint paint, Offset center, double width) {
    final path = Path()
      ..moveTo(center.dx - width, center.dy)
      ..quadraticBezierTo(center.dx - width / 2, center.dy - width * 0.7, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + width / 2, center.dy - width * 0.7, center.dx + width, center.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedSquigglePainter extends CustomPainter {
  _DashedSquigglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.3, 0, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.9, size.width, size.height * 0.4);

    const dashLength = 5.0;
    const gapLength = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSquigglePainter oldDelegate) => oldDelegate.color != color;
}
