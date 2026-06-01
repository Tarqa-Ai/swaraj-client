import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class IQRing extends StatefulWidget {
  final double score;

  const IQRing({super.key, required this.score});

  @override
  State<IQRing> createState() => _IQRingState();
}

class _IQRingState extends State<IQRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double scoreValue = _animation.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(140, 140),
                painter: IQRingPainter(progress: scoreValue / 100.0),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    scoreValue.round().toString(),
                    style: SwarajTypography.headline(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'POLITICAL IQ',
                    style: SwarajTypography.mono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: SwarajColors.slate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class IQRingPainter extends CustomPainter {
  final double progress;

  IQRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width, size.height) / 2.0 - 6.0;
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);

    final Paint bgPaint = Paint()
      ..color = SwarajColors.navy.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, radius, bgPaint);

    final Paint progressPaint = Paint()
      ..color = SwarajColors.saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final double startAngle = -pi / 2.0;
    final double sweepAngle = 2.0 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant IQRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
