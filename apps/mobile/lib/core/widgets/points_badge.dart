import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class PointsBadge extends StatelessWidget {
  final int points;

  const PointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SwarajColors.saffron.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: SwarajColors.saffron.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: SwarajColors.saffron,
          ),
          const SizedBox(width: 6),
          Text(
            '$points',
            style: SwarajTypography.mono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: SwarajColors.saffron,
            ),
          ),
        ],
      ),
    );
  }
}
