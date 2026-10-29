import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Resolution-independent, zero-copyright flat vector brand icon for K-Drama Crosswords.
/// Combines an elegant celadon-sage Soju bottle silhouette and the iconic Korean finger heart.
class BrandIcon extends StatelessWidget {
  final double size;
  final bool showBadgeBackground;

  const BrandIcon({
    super.key,
    this.size = 64,
    this.showBadgeBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BrandIconPainter(showBadgeBackground: showBadgeBackground),
      ),
    );
  }
}

class BrandIconPainter extends CustomPainter {
  final bool showBadgeBackground;

  BrandIconPainter({required this.showBadgeBackground});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    if (showBadgeBackground) {
      // Soft rounded container badge
      final bgPaint = Paint()
        ..color = AppColors.primaryRoseLight
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppColors.primaryRose.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04;

      final badgeRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.28),
      );
      canvas.drawRRect(badgeRRect, bgPaint);
      canvas.drawRRect(badgeRRect, borderPaint);
    }

    // 1. Soju Bottle (Celadon Sage Silhouette - Left side)
    final bottlePaint = Paint()
      ..color = AppColors.sageGreen
      ..style = PaintingStyle.fill;

    final bottlePath = Path();
    // Bottle dimensions relative to w, h
    final bw = w * 0.22;
    final bx = w * 0.22;
    final byBottom = h * 0.82;
    final byShoulder = h * 0.44;
    final byNeck = h * 0.32;
    final byCap = h * 0.26;

    // Base and body
    bottlePath.moveTo(bx - bw / 2, byBottom);
    bottlePath.lineTo(bx + bw / 2, byBottom);
    bottlePath.lineTo(bx + bw / 2, byShoulder);
    // Shoulder curve to neck
    bottlePath.quadraticBezierTo(
      bx + bw / 2,
      byNeck + (byShoulder - byNeck) * 0.4,
      bx + bw * 0.22,
      byNeck,
    );
    // Neck to cap
    bottlePath.lineTo(bx + bw * 0.22, byCap);
    bottlePath.lineTo(bx - bw * 0.22, byCap);
    bottlePath.lineTo(bx - bw * 0.22, byNeck);
    // Left shoulder curve
    bottlePath.quadraticBezierTo(
      bx - bw / 2,
      byNeck + (byShoulder - byNeck) * 0.4,
      bx - bw / 2,
      byShoulder,
    );
    bottlePath.close();
    canvas.drawPath(bottlePath, bottlePaint);

    // Bottle Label (White flat band)
    final labelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(bx, (byShoulder + byBottom) / 2),
        width: bw * 0.8,
        height: (byBottom - byShoulder) * 0.45,
      ),
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(labelRect, labelPaint);

    // 2. Korean Finger Heart (Pastel Rose - Right side)
    final heartPaint = Paint()
      ..color = AppColors.primaryRose
      ..style = PaintingStyle.fill;

    // Small Heart Floating Above Fingers
    final hx = w * 0.65;
    final hy = h * 0.28;
    final hr = w * 0.07;
    final miniHeart = Path();
    miniHeart.moveTo(hx, hy + hr * 0.8);
    miniHeart.cubicTo(
      hx - hr * 1.2,
      hy - hr * 0.2,
      hx - hr * 0.8,
      hy - hr * 1.1,
      hx,
      hy - hr * 0.5,
    );
    miniHeart.cubicTo(
      hx + hr * 0.8,
      hy - hr * 1.1,
      hx + hr * 1.2,
      hy - hr * 0.2,
      hx,
      hy + hr * 0.8,
    );
    canvas.drawPath(miniHeart, heartPaint);

    // Hand / Crossed Fingers Silhouette
    final handPaint = Paint()
      ..color = AppColors.primaryRoseDark
      ..style = PaintingStyle.fill;

    final handPath = Path();
    final fx = w * 0.62;
    final fy = h * 0.48;

    // Stylized crossed thumb & index finger
    handPath.moveTo(fx - w * 0.1, fy + h * 0.32);
    handPath.lineTo(fx + w * 0.18, fy + h * 0.32);
    handPath.quadraticBezierTo(fx + w * 0.18, fy + h * 0.14, fx + w * 0.12, fy + h * 0.1);
    // Index finger tip
    handPath.quadraticBezierTo(fx + w * 0.06, fy - h * 0.04, fx + w * 0.02, fy);
    // Thumb crossed
    handPath.quadraticBezierTo(fx - w * 0.05, fy - h * 0.03, fx - w * 0.06, fy + h * 0.08);
    handPath.quadraticBezierTo(fx - w * 0.1, fy + h * 0.16, fx - w * 0.1, fy + h * 0.32);
    handPath.close();
    canvas.drawPath(handPath, handPaint);

    // 3. Gold Sparkle Stars (Upper Right & Between)
    final starPaint = Paint()
      ..color = AppColors.goldCoin
      ..style = PaintingStyle.fill;

    _drawSparkle(canvas, Offset(w * 0.80, h * 0.22), w * 0.05, starPaint);
    _drawSparkle(canvas, Offset(w * 0.44, h * 0.36), w * 0.035, starPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2;
      final double x = center.dx + math.cos(angle) * radius;
      final double y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final double innerAngle = angle + math.pi / 4;
      final double ix = center.dx + math.cos(innerAngle) * (radius * 0.28);
      final double iy = center.dy + math.sin(innerAngle) * (radius * 0.28);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
