import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      _goToNextScreen();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToNextScreen() {
    if (mounted) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.navy,
      body: GestureDetector(
        onTap: _goToNextScreen,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background glowing sphere decoration
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SwarajColors.saffron.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SWARAJ',
                        style: SwarajTypography.headline(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: SwarajColors.cream,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CustomPaint(
                          painter: EmblemPainter(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCategoryText('Constitution'),
                      _buildDivider(),
                      _buildCategoryText('Government'),
                      _buildDivider(),
                      _buildCategoryText('Elections'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap anywhere to continue',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: SwarajColors.cream.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryText(String title) {
    return Text(
      title,
      style: SwarajTypography.mono(
        fontSize: 11,
        color: SwarajColors.saffron,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: SwarajColors.cream,
        shape: BoxShape.circle,
      ),
    );
  }
}

class EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = SwarajColors.saffron
      ..style = PaintingStyle.fill;

    // Top Triangle
    final Path path1 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.86, size.height * 0.45)
      ..lineTo(size.width * 0.14, size.height * 0.45)
      ..close();
    canvas.drawPath(path1, paint);

    // Bottom Triangle
    final Path path2 = Path()
      ..moveTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.14, size.height * 0.55)
      ..lineTo(size.width * 0.86, size.height * 0.55)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
