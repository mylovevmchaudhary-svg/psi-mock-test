import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    // Transition after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final isLoggedIn = UserModel().isLoggedIn;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) =>
                isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D253F), // Gujarat Police Navy Blue
      body: Stack(
        children: [
          // Background Gradient & Watermark
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    Color(0xFF1E3C72),
                    Color(0xFF0D253F),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Branded Police Emblem / Logo
                    _buildPoliceLogo(),
                    const SizedBox(height: 24),

                    // App Title
                    const Text(
                      'ગુજરાત પોલીસ તૈયારી',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      'કોન્સ્ટેબલ (LRD) & PSI / ASI ભરતી 2026',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFFFC107), // Gold
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mission Khakhi Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, size: 14, color: Color(0xFFFFC107)),
                          SizedBox(width: 6),
                          Text(
                            'મિશન ખાખી 👮‍♂️ • સેવા સુરક્ષા શાંતિ',
                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading Spinner
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Powered by Supabase Cloud Database',
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliceLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 6,
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(140, 140),
        painter: const OfficialPoliceEmblemPainter(),
      ),
    );
  }
}

class OfficialPoliceEmblemPainter extends CustomPainter {
  const OfficialPoliceEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // 1. Outer Deep Navy Background
    final bgPaint = Paint()..color = const Color(0xFF0D253F);
    canvas.drawCircle(center, size.width * 0.48, bgPaint);

    // 2. Dual Metallic Gold Concentric Borders
    final goldBorderPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, size.width * 0.47, goldBorderPaint);

    final innerGoldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, size.width * 0.43, innerGoldPaint);

    // 3. Laurel Wreath Leaves (Gold)
    final leafPaint = Paint()..color = const Color(0xFFFFD700);
    const leafCount = 6;
    for (int i = 0; i < leafCount; i++) {
      final angleL = (115 + (i * 12)) * 3.14159 / 180;
      final lx = cx + (size.width * 0.38) * -angleL; // symmetric curves
      final ly = cy + (size.width * 0.38) * 0.5 + (i * 4);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - (size.width * 0.38), cy + (i * 6) - 10), width: 7, height: 4),
        leafPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + (size.width * 0.38), cy + (i * 6) - 10), width: 7, height: 4),
        leafPaint,
      );
    }

    // 4. Faceted 8-Pointed Golden Star
    final starPath = Path();
    const points = 16;
    final rOuter = size.width * 0.31;
    final rInner = size.width * 0.16;
    for (int i = 0; i < points; i++) {
      final r = i.isEven ? rOuter : rInner;
      final angle = (i * 22.5 - 90) * 3.14159 / 180;
      final x = cx + r * (i.isEven ? 1 : 1) * -1 * (i % 2 == 0 ? 1 : 1);
      final px = cx + r * (i.isEven ? 1 : 1); // star points
    }

    // Draw stylized Star Shield
    final starPaint = Paint()..color = const Color(0xFFFFC107);
    final centerCirclePaint = Paint()..color = const Color(0xFF1E3C72);
    canvas.drawCircle(center, size.width * 0.28, starPaint);
    canvas.drawCircle(center, size.width * 0.25, centerCirclePaint);

    // 5. Center Ashoka / Shield Motif
    final goldFill = Paint()..color = const Color(0xFFFFC107);
    final crestPath = Path();
    crestPath.moveTo(cx, cy - (size.width * 0.20));
    crestPath.lineTo(cx + (size.width * 0.16), cy - (size.width * 0.08));
    crestPath.lineTo(cx + (size.width * 0.12), cy + (size.width * 0.12));
    crestPath.lineTo(cx, cy + (size.width * 0.20));
    crestPath.lineTo(cx - (size.width * 0.12), cy + (size.width * 0.12));
    crestPath.lineTo(cx - (size.width * 0.16), cy - (size.width * 0.08));
    crestPath.close();
    canvas.drawPath(crestPath, Paint()..color = const Color(0xFF0D253F));
    canvas.drawPath(crestPath, Paint()..color = const Color(0xFFFFC107)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 6. Text: "PSI" & "GUJARAT"
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'GUJARAT POLICE',
      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFFFFC107), letterSpacing: 0.8),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - (textPainter.width / 2), cy - (size.width * 0.35)));

    textPainter.text = const TextSpan(
      text: 'PSI',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - (textPainter.width / 2), cy - 10));

    // 7. Ribbon Banner at bottom: "સેવા સુરક્ષા"
    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + (size.width * 0.32)), width: size.width * 0.72, height: 18),
      const Radius.circular(9),
    );
    canvas.drawRRect(bannerRect, Paint()..color = const Color(0xFFFFC107));
    canvas.drawRRect(bannerRect, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1);

    textPainter.text = const TextSpan(
      text: 'સેવા • સુરક્ષા • શાંતિ',
      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF0D253F)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - (textPainter.width / 2), cy + (size.width * 0.32) - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
