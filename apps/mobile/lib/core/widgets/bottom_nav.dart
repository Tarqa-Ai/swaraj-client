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
        color: Colors.white.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(
            color: Color(0x0F0B1F3A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home),
          _buildNavItem(1, 'Learn', Icons.book_outlined, Icons.book),
          _buildNavItem(
              2, 'Debate', Icons.chat_bubble_outline, Icons.chat_bubble),
          _buildNavItem(
              3, 'AI', Icons.auto_awesome_outlined, Icons.auto_awesome),
          _buildNavItem(4, 'Profile', Icons.person_outline, Icons.person),
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
            Icon(
              isActive ? filledIcon : outlineIcon,
              size: 22,
              color: isActive ? SwarajColors.navy : SwarajColors.slateLight,
            ),
            const SizedBox(height: 4),
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
