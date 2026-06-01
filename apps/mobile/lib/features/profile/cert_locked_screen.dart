import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class CertLockedScreen extends StatelessWidget {
  const CertLockedScreen({super.key});

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
        title: Text(
          'SWARAJ',
          style: SwarajTypography.headline(
              fontSize: 18, fontWeight: FontWeight.w800),
        ),
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
            Text(
              'ACHIEVEMENT MERIT',
              style: SwarajTypography.mono(
                  fontSize: 11, color: SwarajColors.saffron),
            ),
            const SizedBox(height: 4),
            Text(
              'Civic Excellence',
              style: SwarajTypography.headline(
                  fontSize: 36, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SwarajColors.saffron.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 32,
                      color: SwarajColors.saffron,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Requirement Pending',
                    style: SwarajTypography.headline(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your official certificate of completion is waiting. Complete the remaining modules to unlock it.',
                    textAlign: TextAlign.center,
                    style: SwarajTypography.body(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modules Completed',
                        style: SwarajTypography.mono(
                            fontSize: 12, color: SwarajColors.slate),
                      ),
                      Text(
                        '3 / 5',
                        style: SwarajTypography.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 6,
                      backgroundColor: SwarajColors.surface,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(SwarajColors.saffron),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwarajColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'CONTINUE LEARNING',
                        style: SwarajTypography.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Remaining Module',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SwarajColors.navy.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: SwarajColors.navy.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '05',
                      style: SwarajTypography.mono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: SwarajColors.navy),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Judiciary & Remedies',
                          style: SwarajTypography.body(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: SwarajColors.navy),
                        ),
                        Text(
                          'Estimated Time: 25 Mins',
                          style: SwarajTypography.mono(
                              fontSize: 11, color: SwarajColors.slateLight),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: SwarajColors.slateLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
