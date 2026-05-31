import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';
import 'widgets/quiz_overlay.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  void _openQuiz(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuizOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: SwarajColors.navy),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SwarajColors.navy,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.shield,
                size: 14,
                color: SwarajColors.saffron,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SWARAJ',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: PointsBadge(points: 12),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'CIVICS 101',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.slateLight),
                ),
                const SizedBox(width: 8),
                Text(
                  '|',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.outlineVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  '15 MIN READ',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.slateLight),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'How a Bill Becomes Law',
              style: SwarajTypography.headline(
                  fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/dome.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'The legislative process is the backbone of democracy. In India, the journey of a bill from a mere proposal to a binding Act is a rigorous path involving both Houses of Parliament—the Lok Sabha and the Rajya Sabha—and finally, the assent of the President.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Introduction of the Bill',
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A bill can be introduced in either house of Parliament. Most legislative proposals are introduced by Ministers as Government Bills, though Private Members can also introduce proposals.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: SwarajColors.navy.withValues(alpha: 0.03),
                border: const Border(
                  left: BorderSide(
                    color: SwarajColors.saffron,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                '"Every law begins as a vision for a better society, codified into language that governs our collective future."',
                style: SwarajTypography.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: SwarajColors.navy,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '2. Three Readings',
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Each House follows a 'Three Reading' process. The first reading is the formal introduction. The second reading is where the bill is examined clause by clause, often being referred to a Select Committee for detailed scrutiny. The third reading is the final vote.",
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _openQuiz(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TEST KNOWLEDGE',
                      style: SwarajTypography.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.psychology,
                    size: 18, color: SwarajColors.navy),
                label: Text(
                  'EXPLAIN SIMPLY (AI)',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SwarajColors.navy,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
