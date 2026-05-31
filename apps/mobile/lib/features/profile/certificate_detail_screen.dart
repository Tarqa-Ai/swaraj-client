import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key});

  void _showMockToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                    'SHARE CERTIFICATE',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: SwarajColors.saffron),
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
                'Showcase your achievement to your network and peers.',
                style: SwarajTypography.body(fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildShareOption(
                icon: Icons.picture_as_pdf,
                iconBgColor: SwarajColors.error,
                title: 'Download PDF',
                subtitle: 'High-resolution printable version',
                onTap: () {
                  Navigator.pop(context);
                  _showMockToast(context, 'PDF download started');
                },
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.link,
                iconBgColor: SwarajColors.navy,
                title: 'Copy Link',
                subtitle: 'Share unique verification URL',
                onTap: () {
                  Navigator.pop(context);
                  _showMockToast(
                      context, 'Verification link copied to clipboard!');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconBgColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SwarajTypography.body(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: SwarajColors.navy),
                  ),
                  Text(
                    subtitle,
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.slateLight),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SwarajColors.slateLight),
          ],
        ),
      ),
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
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: SwarajColors.saffron.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars,
                      size: 14, color: SwarajColors.saffron),
                  const SizedBox(width: 6),
                  Text(
                    'ACHIEVEMENT UNLOCKED',
                    style: SwarajTypography.mono(
                        fontSize: 10,
                        color: SwarajColors.saffron,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Congratulations, Leader.',
              textAlign: TextAlign.center,
              style: SwarajTypography.headline(
                  fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully completed the Foundations of Civic Responsibility course with honors.',
              textAlign: TextAlign.center,
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SwarajColors.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SwarajColors.saffron.withValues(alpha: 0.4),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: SwarajColors.navy.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'SWARAJ',
                    style: SwarajTypography.headline(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: SwarajColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1.5,
                    width: 60,
                    color: SwarajColors.saffron,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CERTIFICATE OF EXCELLENCE',
                    style: SwarajTypography.mono(
                        fontSize: 10,
                        color: SwarajColors.saffron,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Certified Young Civic Leader',
                    style: SwarajTypography.headline(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This official document certifies that',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.slateLight),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Arjun K. Sharma',
                    style: SwarajTypography.headline(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: SwarajColors.navy),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'has demonstrated exceptional proficiency in Constitutional Law, Public Policy, and Active Citizenship, completing all modules with an aggregate score of 98%.',
                    textAlign: TextAlign.center,
                    style: SwarajTypography.body(fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: SwarajColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech,
                      size: 32,
                      color: SwarajColors.saffron,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATE OF ISSUE',
                            style: SwarajTypography.mono(
                                fontSize: 8, color: SwarajColors.slateLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'October 24, 2023',
                            style: SwarajTypography.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: SwarajColors.navy),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CERTIFICATE ID',
                            style: SwarajTypography.mono(
                                fontSize: 8, color: SwarajColors.slateLight),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SRJ-2023-889-V',
                            style: SwarajTypography.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: SwarajColors.navy),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"IN THE SPIRIT OF THE NATIONAL YOUTH POLICY 2026"',
                    textAlign: TextAlign.center,
                    style: SwarajTypography.mono(
                      fontSize: 8,
                      color: SwarajColors.navy.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showMockToast(context, 'PDF download started'),
                    icon: const Icon(Icons.download, size: 16),
                    label: Text(
                      'DOWNLOAD PDF',
                      style: SwarajTypography.mono(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openShareSheet(context),
                    icon: const Icon(Icons.share,
                        size: 16, color: SwarajColors.navy),
                    label: Text(
                      'SHARE NOW',
                      style: SwarajTypography.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: SwarajColors.navy),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: SwarajColors.navy.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
