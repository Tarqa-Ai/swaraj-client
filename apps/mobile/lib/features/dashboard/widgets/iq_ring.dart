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
  void didUpdateWidget(IQRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      setState(() {
        _animation = Tween<double>(
          begin: _animation.value,
          end: widget.score,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
      });
      _controller.forward(from: 0.0);
    }
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
                  SlotMachineScore(
                    score: widget.score.round(),
                    style: SwarajTypography.headline(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
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

class SlotMachineScore extends StatelessWidget {
  final int score;
  final TextStyle style;

  const SlotMachineScore({super.key, required this.score, required this.style});

  @override
  Widget build(BuildContext context) {
    final digits = score.toString().split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((digit) {
        final d = int.tryParse(digit) ?? 0;
        return RollingDigit(digit: d, style: style);
      }).toList(),
    );
  }
}

class RollingDigit extends StatefulWidget {
  final int digit;
  final TextStyle style;

  const RollingDigit({super.key, required this.digit, required this.style});

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.digit.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.digit.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final fontSize = widget.style.fontSize ?? 40.0;
    final digitHeight = fontSize * 1.5;

    return SizedBox(
      width: fontSize * 0.72,
      height: digitHeight,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final val = _animation.value;
            return Stack(
              children: [
                Transform.translate(
                  offset: Offset(0, -val * digitHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(10, (index) {
                      return SizedBox(
                        height: digitHeight,
                        child: Center(
                          child: Text(
                            index.toString(),
                            style: widget.style.copyWith(
                              height: 1.0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
