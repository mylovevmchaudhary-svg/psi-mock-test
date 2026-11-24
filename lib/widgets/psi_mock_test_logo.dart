import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-Premium 3D Heraldic Emblem Widget for PSI Mock Test
/// Features metallic gold bevels, dual 3D officer stars, laurel wreaths,
/// and embossed typography with realistic lighting and shadows.
class PsiMockTestLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const PsiMockTestLogo({
    super.key,
    this.size = 140,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.35),
                  blurRadius: size * 0.22,
                  spreadRadius: size * 0.04,
                ),
                BoxShadow(
                  color: const Color(0xFF0A192F).withOpacity(0.5),
                  blurRadius: size * 0.15,
                  offset: Offset(0, size * 0.06),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: Psi3DEmblemPainter(),
      ),
    );
  }
}

class Psi3DEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final radius = size.width / 2;

    // 1. Deep 3D Drop Shadow for the entire badge
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.06);
    canvas.drawCircle(Offset(cx, cy + size.width * 0.03), radius * 0.94, shadowPaint);

    // 2. Outer 3D Metallic Gold Ring (Beveled Gradient)
    final outerGoldShader = RadialGradient(
      center: const Alignment(-0.35, -0.35),
      radius: 0.9,
      colors: const [
        Color(0xFFFFF7D6), // Bright highlight
        Color(0xFFFFD700), // Pure gold
        Color(0xFFDAA520), // Goldenrod
        Color(0xFFB8860B), // Dark goldenrod
        Color(0xFF5C4033), // Deep bronze shadow
      ],
      stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.94, Paint()..shader = outerGoldShader);

    // 3. Bevel Rim Groove (Inner shadow ring)
    final groovePaint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012;
    canvas.drawCircle(center, radius * 0.86, groovePaint);

    final rimHighlight = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008;
    canvas.drawCircle(center, radius * 0.85, rimHighlight);

    // 4. Center Midnight Blue 3D Shield Disc
    final innerDiscShader = RadialGradient(
      center: const Alignment(-0.25, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFF1E3A8A), // Vibrant Royal Navy
        Color(0xFF0F172A), // Dark Slate Navy
        Color(0xFF0A0F1D), // Deepest Midnight Navy
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius * 0.82));

    canvas.drawCircle(center, radius * 0.82, Paint()..shader = innerDiscShader);

    // 5. High-Precision 3D Laurel Wreath (Symmetric Gold Leaves on sides)
    final leafHighlightPaint = Paint()..color = const Color(0xFFFFE082);
    final leafShadowPaint = Paint()..color = const Color(0xFFB78103);

    void draw3DLeaf(double x, double y, double rotation, double leafSize) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final pathLeft = Path()
        ..moveTo(0, -leafSize)
        ..quadraticBezierTo(-leafSize * 0.5, 0, 0, leafSize)
        ..close();
      canvas.drawPath(pathLeft, leafHighlightPaint);

      final pathRight = Path()
        ..moveTo(0, -leafSize)
        ..quadraticBezierTo(leafSize * 0.5, 0, 0, leafSize)
        ..close();
      canvas.drawPath(pathRight, leafShadowPaint);

      canvas.restore();
    }

    const int leavesPerSide = 5;
    for (int i = 0; i < leavesPerSide; i++) {
      final angleFraction = (i / (leavesPerSide - 1));
      final angleLeft = math.pi * 0.65 + angleFraction * math.pi * 0.55;
      final angleRight = math.pi * 0.35 - angleFraction * math.pi * 0.55;
      final rDist = radius * 0.72;

      final lx = cx + rDist * math.cos(angleLeft);
      final ly = cy + rDist * math.sin(angleLeft);
      draw3DLeaf(lx, ly, angleLeft + math.pi / 2, size.width * 0.045);

      final rx = cx + rDist * math.cos(angleRight);
      final ry = cy + rDist * math.sin(angleRight);
      draw3DLeaf(rx, ry, angleRight - math.pi / 2, size.width * 0.045);
    }

    // 6. Center 3D Heraldic Shield
    final shieldTop = cy - size.width * 0.28;
    final shieldBottom = cy + size.width * 0.16;
    final shieldHalfW = size.width * 0.26;

    final shieldPath = Path()
      ..moveTo(cx, shieldTop)
      ..lineTo(cx + shieldHalfW, shieldTop + size.width * 0.08)
      ..lineTo(cx + shieldHalfW * 0.85, cy + size.width * 0.06)
      ..lineTo(cx, shieldBottom)
      ..lineTo(cx - shieldHalfW * 0.85, cy + size.width * 0.06)
      ..lineTo(cx - shieldHalfW, shieldTop + size.width * 0.08)
      ..close();

    // Shield 3D Shadow
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02),
    );

    // Shield Metallic Fill
    final shieldShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFF1E293B),
        Color(0xFF0F172A),
        Color(0xFF020617),
      ],
    ).createShader(Rect.fromCenter(center: center, width: shieldHalfW * 2, height: shieldBottom - shieldTop));
    canvas.drawPath(shieldPath, Paint()..shader = shieldShader);

    // Shield Gold Bevel Border
    canvas.drawPath(
      shieldPath,
      Paint()
        ..shader = outerGoldShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.016,
    );

    // 7. Dual 3D Officer Gold Stars (Sub-Inspector Rank Emblem)
    void draw3DStar(double sx, double sy, double starRadius) {
      canvas.save();
      canvas.translate(sx, sy);

      final numPoints = 5;
      final step = math.pi / numPoints;

      for (int i = 0; i < numPoints; i++) {
        final a1 = i * 2 * step - math.pi / 2;
        final aMid = a1 + step;
        final a2 = a1 + 2 * step;

        final pCenter = Offset.zero;
        final pTip = Offset(starRadius * math.cos(a1), starRadius * math.sin(a1));
        final pInner = Offset(starRadius * 0.42 * math.cos(aMid), starRadius * 0.42 * math.sin(aMid));

        // Light facet
        final pathLight = Path()
          ..moveTo(pCenter.dx, pCenter.dy)
          ..lineTo(pTip.dx, pTip.dy)
          ..lineTo(pInner.dx, pInner.dy)
          ..close();
        canvas.drawPath(pathLight, Paint()..color = const Color(0xFFFFF176));

        // Shadow facet
        final aPrevInner = a1 - step;
        final pPrevInner = Offset(starRadius * 0.42 * math.cos(aPrevInner), starRadius * 0.42 * math.sin(aPrevInner));
        final pathShadow = Path()
          ..moveTo(pCenter.dx, pCenter.dy)
          ..lineTo(pTip.dx, pTip.dy)
          ..lineTo(pPrevInner.dx, pPrevInner.dy)
          ..close();
        canvas.drawPath(pathShadow, Paint()..color = const Color(0xFFC69200));
      }
      canvas.restore();
    }

    final starY = shieldTop + size.width * 0.08;
    final starSpread = size.width * 0.085;
    draw3DStar(cx - starSpread, starY, size.width * 0.048);
    draw3DStar(cx + starSpread, starY, size.width * 0.048);

    // 8. 3D Embossed Bold Typography: "PSI"
    final psiTextPainter = TextPainter(textDirection: TextDirection.ltr);

    // 3D Drop shadow for "PSI"
    psiTextPainter.text = TextSpan(
      text: 'PSI',
      style: TextStyle(
        fontSize: size.width * 0.22,
        fontWeight: FontWeight.w900,
        color: Colors.black.withOpacity(0.6),
        letterSpacing: 2.5,
        fontFamily: 'serif',
      ),
    );
    psiTextPainter.layout();
    psiTextPainter.paint(canvas, Offset(cx - psiTextPainter.width / 2, cy - size.width * 0.095));

    // Metallic Gradient for "PSI" text
    final psiShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFF9C4), // Light gold highlight
        Color(0xFFFFD700), // Solid gold
        Color(0xFFDAA520), // Darker gold
      ],
    ).createShader(Rect.fromLTWH(cx - psiTextPainter.width / 2, cy - size.width * 0.11, psiTextPainter.width, psiTextPainter.height));

    psiTextPainter.text = TextSpan(
      text: 'PSI',
      style: TextStyle(
        fontSize: size.width * 0.22,
        fontWeight: FontWeight.w900,
        foreground: Paint()..shader = psiShader,
        letterSpacing: 2.5,
        fontFamily: 'serif',
      ),
    );
    psiTextPainter.layout();
    psiTextPainter.paint(canvas, Offset(cx - psiTextPainter.width / 2, cy - size.width * 0.11));

    // 9. 3D Metallic Curved Ribbon Banner at Bottom: "MOCK TEST"
    final bannerY = cy + size.width * 0.26;
    final bannerW = size.width * 0.74;
    final bannerH = size.width * 0.14;

    // Banner Drop Shadow
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, bannerY + 2), width: bannerW, height: bannerH),
      Radius.circular(bannerH * 0.35),
    );
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02),
    );

    // Banner Metallic Gold Body
    final bannerShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFFFF59D), // Top highlight
        Color(0xFFFFD700), // Middle rich gold
        Color(0xFFB8860B), // Bottom shadow
      ],
    ).createShader(Rect.fromCenter(center: Offset(cx, bannerY), width: bannerW, height: bannerH));

    final actualBannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, bannerY), width: bannerW, height: bannerH),
      Radius.circular(bannerH * 0.35),
    );
    canvas.drawRRect(actualBannerRect, Paint()..shader = bannerShader);

    // Inner gold border line on ribbon
    canvas.drawRRect(
      actualBannerRect,
      Paint()
        ..color = const Color(0xFF5C4033)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008,
    );

    // Text: "MOCK TEST" inside Banner
    final bannerTextPainter = TextPainter(textDirection: TextDirection.ltr);
    bannerTextPainter.text = TextSpan(
      text: 'MOCK TEST',
      style: TextStyle(
        fontSize: size.width * 0.072,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0A192F), // Deep Navy for sharp contrast
        letterSpacing: 2.2,
      ),
    );
    bannerTextPainter.layout();
    bannerTextPainter.paint(
      canvas,
      Offset(cx - bannerTextPainter.width / 2, bannerY - bannerTextPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
