import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class SwarajBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SwarajBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 72 + paddingBottom,
      padding: EdgeInsets.only(bottom: paddingBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: SwarajColors.navy.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
          _buildNavItem(1, 'Learn', Icons.menu_book_outlined, Icons.menu_book),
          _buildNavItem(2, 'Debate', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded),
          _buildNavItem(3, 'AI', Icons.auto_awesome_outlined, Icons.auto_awesome),
          _buildNavItem(4, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, String label, IconData outlineIcon, IconData filledIcon) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? SwarajColors.navy.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? filledIcon : outlineIcon,
                size: 22,
                color: isActive ? SwarajColors.navy : SwarajColors.slateLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: SwarajTypography.mono(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? SwarajColors.navy : SwarajColors.slateLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
