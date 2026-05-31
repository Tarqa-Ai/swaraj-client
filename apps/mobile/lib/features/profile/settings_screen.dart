import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onResetAllData;

  const SettingsScreen({super.key, required this.onResetAllData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  void _showMockToast(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeletion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Account?',
            style: SwarajTypography.headline(
                fontSize: 20, color: SwarajColors.error),
          ),
          content: Text(
            'Are you sure you want to permanently delete your Swaraj account and erase all points, leaderboards, and certifications? This action is immediate and completely irreversible.',
            style: SwarajTypography.body(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: SwarajTypography.mono(
                    fontSize: 12, color: SwarajColors.navy),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeDeletion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwarajColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                'DELETE',
                style: SwarajTypography.mono(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeDeletion() {
    setState(() {
      _isDeleting = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });

      // Reset application points and state globally
      widget.onResetAllData();

      _showMockToast('All associated civic data erased successfully.',
          SwarajColors.success);

      // Navigate back to the login screen and clear history stack
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRIVACY POLICY',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.saffron),
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
                'Data Safety & Privacy Assurance',
                style: SwarajTypography.headline(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Account Information',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We collect only your phone number to secure your profile and OTP login. We do not store or transmit contacts or personal documents.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '2. Progress Tracking & Badges',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your module progress, Political IQ score, quiz submissions, and earned merit certifications are securely tied to your profile to generate leaderboards.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '3. Data Erasure Rights',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complying with App Store Guideline 5.1.1, you maintain full authority to erase your account and all associated profile, certification, and learning databases instantly from this panel.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CLOSE',
                    style: SwarajTypography.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showTermsOfService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TERMS OF SERVICE',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.saffron),
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
                'Swaraj Platform Guidelines',
                style: SwarajTypography.headline(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Learning & Participation',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Swaraj is an educational platform intended to promote constitutional literacy among young citizens in active alignment with the ECI SVEEP mission.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '2. Leaderboard & Content Integrity',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Users must construct respectful and policy-focused arguments on the debate boards. Spamming, plagiarism, or offensive content will lead to immediate profile lock.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '3. Certification Verification',
                        style: SwarajTypography.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All merit certificates generated on Swaraj are digitally signed and verifiable. Falsification or tampering with certificate records violates platform standards.',
                        style: SwarajTypography.body(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CLOSE',
                    style: SwarajTypography.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showContactSupport() {
    final TextEditingController supportInputController =
        TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
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
                    Text(
                      'CONTACT SUPPORT',
                      style: SwarajTypography.mono(
                          fontSize: 10, color: SwarajColors.saffron),
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
                  'Reach Out to Swaraj Team',
                  style: SwarajTypography.headline(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Have questions about constitutional modules, certification delivery, or playstore policies? Direct emails can be sent to support@swaraj-learning.org.',
                  style: SwarajTypography.body(fontSize: 13),
                ),
                const SizedBox(height: 16),
                Text(
                  'SEND AN INSTANT INQUIRY',
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: supportInputController,
                  maxLines: 3,
                  style: SwarajTypography.body(
                      fontSize: 14, color: SwarajColors.navy),
                  decoration: InputDecoration(
                    hintText: 'Type your message or bug report here...',
                    hintStyle: SwarajTypography.body(
                        fontSize: 14, color: SwarajColors.outline),
                    filled: true,
                    fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: SwarajColors.navy.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final text = supportInputController.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(context);
                      _showMockToast(
                          'Message sent! Our support team will respond shortly.',
                          SwarajColors.success);
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
                      'SEND MESSAGE',
                      style: SwarajTypography.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: SwarajColors.cream,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: SwarajColors.navy),
            ),
            title: Text(
              'App Settings',
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
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
                  'SWARAJ CONFIGURATION',
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: SwarajColors.navy.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Profile & Security',
                        onTap: () => _showMockToast(
                            'Profile security is fully managed via custom OTP.',
                            SwarajColors.navy),
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        icon: Icons.shield,
                        title: 'Privacy Policy',
                        onTap: _showPrivacyPolicy,
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: _showTermsOfService,
                      ),
                      const Divider(height: 1),
                      _buildSettingsItem(
                        icon: Icons.mail_outline,
                        title: 'Contact Support',
                        onTap: _showContactSupport,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SwarajColors.error.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: SwarajColors.error.withValues(alpha: 0.3),
                        width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: SwarajTypography.headline(
                            fontSize: 16,
                            color: SwarajColors.error,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Permanently delete your Swaraj account, all earned points, leaderboards, and merit certificates. This action is immediate and completely irreversible under playstore rules.',
                        style: SwarajTypography.body(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _confirmDeletion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SwarajColors.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'DELETE ACCOUNT & DATA',
                            style: SwarajTypography.mono(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isDeleting)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(SwarajColors.saffron),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erasing Account Data...',
                    style: SwarajTypography.body(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SwarajColors.navy),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: SwarajColors.navy),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: SwarajTypography.body(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SwarajColors.navy),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: SwarajColors.slateLight),
          ],
        ),
      ),
    );
  }
}
