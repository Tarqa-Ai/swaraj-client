import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class QuizOverlay extends StatefulWidget {
  const QuizOverlay({super.key});

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  int? _selectedIndex;
  bool _answered = false;

  final List<String> _options = [
    'Rajya Sabha only',
    'Lok Sabha only',
    'Either House',
    'Joint Session',
  ];

  final int _correctIndex = 1;

  void _onOptionSelected(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    final bool isCorrect = index == _correctIndex;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Correct! Well done.'
              : 'Not quite. The correct answer is highlighted.',
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isCorrect ? SwarajColors.success : SwarajColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KNOWLEDGE CHECK',
                style: SwarajTypography.mono(
                    fontSize: 11, color: SwarajColors.saffron),
              ),
              Text(
                'Question 1 of 3',
                style: SwarajTypography.mono(
                    fontSize: 11, color: SwarajColors.slateLight),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'In which house can a Money Bill be introduced?',
            style: SwarajTypography.headline(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(4, (index) {
              final String letter = ['A', 'B', 'C', 'D'][index];
              final String text = _options[index];

              Color borderColor = SwarajColors.navy.withValues(alpha: 0.12);
              Color bgColor = Colors.white;
              Color letterColor = SwarajColors.navy;

              if (_answered) {
                if (index == _correctIndex) {
                  borderColor = SwarajColors.success;
                  bgColor = SwarajColors.success.withValues(alpha: 0.08);
                  letterColor = SwarajColors.success;
                } else if (_selectedIndex == index) {
                  borderColor = SwarajColors.error;
                  bgColor = SwarajColors.error.withValues(alpha: 0.08);
                  letterColor = SwarajColors.error;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _onOptionSelected(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _answered &&
                                    (index == _correctIndex ||
                                        _selectedIndex == index)
                                ? Colors.transparent
                                : SwarajColors.navy.withValues(alpha: 0.04),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _answered &&
                                      (index == _correctIndex ||
                                          _selectedIndex == index)
                                  ? Colors.transparent
                                  : SwarajColors.navy.withValues(alpha: 0.08),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: SwarajTypography.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: letterColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            text,
                            style: SwarajTypography.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: SwarajColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _answered ? () => Navigator.pop(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SwarajColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    SwarajColors.navy.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE',
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
        ],
      ),
    );
  }
}
