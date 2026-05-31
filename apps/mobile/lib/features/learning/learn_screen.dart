import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';

class LearnScreen extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  final int points;
  final ValueChanged<int> onPointsEarned;

  const LearnScreen({
    super.key,
    required this.onTabChange,
    required this.points,
    required this.onPointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: PointsBadge(points: points),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACADEMY',
              style: SwarajTypography.mono(
                  fontSize: 11, color: SwarajColors.saffron),
            ),
            const SizedBox(height: 4),
            Text(
              'Curriculum',
              style: SwarajTypography.headline(
                  fontSize: 36, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Master the architecture of democracy through structured, evidence-based modules.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search topics...',
                hintStyle: SwarajTypography.body(color: SwarajColors.outline),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: SwarajColors.slateLight),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: SwarajColors.saffron, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildModuleCard(
              context,
              number: '01',
              category: 'FOUNDATIONS',
              title: 'The Constitutional Bedrock',
              desc:
                  'Explore the preamble, historical drafting, and the core values that define the Indian Republic.',
              lessonsText: '8 / 12 Lessons',
              progress: 0.66,
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              number: '02',
              category: 'YOUR RIGHTS',
              title: 'Civil Liberties & Duties',
              desc:
                  'A deep dive into Fundamental Rights and the responsibilities of every citizen.',
              lessonsText: '3 / 10 Lessons',
              progress: 0.30,
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              number: '03',
              category: 'JUDICIARY',
              title: 'The Gavel of Justice',
              desc:
                  'Understanding the hierarchy of courts and the power of Judicial Review.',
              lessonsText: '12 / 12 Lessons',
              progress: 1.0,
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              number: '04',
              category: 'ELECTIONS',
              title: 'The Power of the Vote',
              desc:
                  'Electoral systems, political parties, and the mechanics of a modern democracy.',
              lessonsText: '0 / 8 Lessons',
              progress: 0.0,
            ),
            const SizedBox(height: 16),
            SamvidhanWheelCard(onPointsEarned: onPointsEarned),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SwarajColors.saffron.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SwarajColors.saffron.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 28,
                      color: SwarajColors.saffron,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confused by Legalese?',
                          style: SwarajTypography.headline(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask Swaraj AI to explain any constitutional concept simply.',
                          style: SwarajTypography.body(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => onTabChange(3),
                          icon: const Icon(Icons.psychology, size: 16),
                          label: Text(
                            'EXPLAIN SIMPLY',
                            style: SwarajTypography.mono(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SwarajColors.navy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String number,
    required String category,
    required String title,
    required String desc,
    required String lessonsText,
    required double progress,
  }) {
    final bool isCompleted = progress == 1.0;
    final bool isNotStarted = progress == 0.0;

    Color textColor = SwarajColors.navy;
    Color progressColor = SwarajColors.saffron;
    if (isCompleted) {
      textColor = SwarajColors.success;
      progressColor = SwarajColors.success;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/lesson'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? SwarajColors.success.withValues(alpha: 0.2)
                : SwarajColors.navy.withValues(alpha: 0.1),
            width: isCompleted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  number,
                  style: SwarajTypography.mono(
                    fontSize: 14,
                    color: isCompleted
                        ? SwarajColors.success
                        : SwarajColors.saffron,
                  ),
                ),
                Text(
                  category,
                  style: SwarajTypography.mono(
                    fontSize: 11,
                    color: SwarajColors.slateLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: SwarajTypography.body(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: SwarajColors.navy.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lessonsText,
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SwarajColors.slate,
                  ),
                ),
                Text(
                  isCompleted
                      ? 'COMPLETE'
                      : isNotStarted
                          ? 'NOT STARTED'
                          : '${(progress * 100).round()}%',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SamvidhanWheelCard extends StatefulWidget {
  final ValueChanged<int> onPointsEarned;

  const SamvidhanWheelCard({super.key, required this.onPointsEarned});

  @override
  State<SamvidhanWheelCard> createState() => _SamvidhanWheelCardState();
}

class _SamvidhanWheelCardState extends State<SamvidhanWheelCard>
    with SingleTickerProviderStateMixin {
  bool _isSpun = false;
  String _buttonText = 'SPIN DAILY WHEEL';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpun) return;
    setState(() {
      _isSpun = true;
      _buttonText = 'SPINNING...';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Spinning Samvidhan Wheel...',
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _animationController.repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _animationController.stop();
      setState(() {
        _buttonText = 'SPUN TODAY';
      });
      _showQuizBottomSheet();
    });
  }

  void _showQuizBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SamvidhanWheelQuizSheet(onPointsEarned: widget.onPointsEarned);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SwarajColors.saffron.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: RotationTransition(
              turns: _animation,
              child: const Text(
                '🔆',
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SwarajColors.saffron.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'DAILY BONUS',
                    style: SwarajTypography.mono(
                      fontSize: 9,
                      color: SwarajColors.saffron,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Samvidhan Wheel',
                  style: SwarajTypography.headline(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Spin the daily wheel to explore a surprise constitutional topic! Get +20 points.',
                  style: SwarajTypography.body(fontSize: 13),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _isSpun ? null : _spinWheel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.saffron,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          SwarajColors.saffron.withValues(alpha: 0.4),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _buttonText.toUpperCase(),
                      style: SwarajTypography.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SamvidhanWheelQuizSheet extends StatefulWidget {
  final ValueChanged<int> onPointsEarned;

  const SamvidhanWheelQuizSheet({super.key, required this.onPointsEarned});

  @override
  State<SamvidhanWheelQuizSheet> createState() =>
      _SamvidhanWheelQuizSheetState();
}

class _SamvidhanWheelQuizSheetState extends State<SamvidhanWheelQuizSheet> {
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  final List<String> _options = [
    'Right to Property',
    'Right to Privacy',
    'Right to Form Associations',
    'Right to Bear Arms'
  ];

  final int _correctIndex = 1;

  void _onOptionTap(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
    });

    if (index == _correctIndex) {
      widget.onPointsEarned(20);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correct! +20 Points earned.',
            style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: SwarajColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incorrect. The correct answer is highlighted.',
            style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: SwarajColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SwarajColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SwarajColors.saffron.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'DAILY WHEEL BONUS',
                  style: SwarajTypography.mono(
                    fontSize: 9,
                    color: SwarajColors.saffron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close,
                    size: 20, color: SwarajColors.slateLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Article 21: Protection of Life and Liberty',
            style: SwarajTypography.headline(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Article 21 guarantees that "No person shall be deprived of his life or personal liberty except according to procedure established by law." The Supreme Court has expansively interpreted this right over decades to include crucial protections such as the Right to Privacy (Puttaswamy judgment), Right to a Clean Environment, Right to Free Education up to 14 years, and the Right to Dignity.',
            style: SwarajTypography.body(fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'QUIZ QUESTION',
            style: SwarajTypography.mono(
                fontSize: 10, color: SwarajColors.saffron),
          ),
          const SizedBox(height: 6),
          Text(
            'Which right is protected under the expanded scope of Article 21?',
            style: SwarajTypography.body(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(_options.length, (index) {
            final optionText = _options[index];
            final bool isSelected = _selectedOptionIndex == index;
            final bool isCorrectOption = index == _correctIndex;

            Color itemBorderColor = SwarajColors.navy.withValues(alpha: 0.1);
            Color itemBgColor = Colors.white;
            IconData? feedbackIcon;
            Color? feedbackIconColor;

            if (_isAnswered) {
              if (isSelected) {
                if (isCorrectOption) {
                  itemBorderColor = SwarajColors.success;
                  itemBgColor = SwarajColors.success.withValues(alpha: 0.06);
                  feedbackIcon = Icons.check_circle;
                  feedbackIconColor = SwarajColors.success;
                } else {
                  itemBorderColor = SwarajColors.error;
                  itemBgColor = SwarajColors.error.withValues(alpha: 0.06);
                  feedbackIcon = Icons.cancel;
                  feedbackIconColor = SwarajColors.error;
                }
              } else if (isCorrectOption) {
                itemBorderColor = SwarajColors.success;
                itemBgColor = SwarajColors.success.withValues(alpha: 0.04);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _onOptionTap(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: itemBgColor,
                    border: Border.all(
                        color: itemBorderColor,
                        width: isSelected || (isCorrectOption && _isAnswered)
                            ? 1.5
                            : 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : SwarajColors.navy.withValues(alpha: 0.12),
                          ),
                          color: isSelected
                              ? (isCorrectOption
                                  ? SwarajColors.success
                                  : SwarajColors.error)
                              : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : Text(
                                String.fromCharCode(65 + index),
                                style: SwarajTypography.mono(
                                    fontSize: 10, color: SwarajColors.navy),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: SwarajTypography.body(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                      if (feedbackIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(feedbackIcon, size: 18, color: feedbackIconColor),
                      ]
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isAnswered ? () => Navigator.pop(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SwarajColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    SwarajColors.navy.withValues(alpha: 0.4),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'CONTINUE',
                style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
