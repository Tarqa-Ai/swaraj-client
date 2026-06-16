import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import 'data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _phoneController.addListener(_validate);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validate() {
    final email = _emailController.text.trim();
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final emailValid = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(email);
    final phoneValid = digits.length == 10 && RegExp(r'^[6-9]').hasMatch(digits);
    setState(() {
      _isButtonEnabled = emailValid && phoneValid && _termsAccepted;
      _error = null;
    });
  }

  void _showPolicySheet(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: SwarajColors.navy.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: SwarajTypography.headline(fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: SwarajColors.navy.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: SwarajColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: SwarajColors.navy.withValues(alpha: 0.08), height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Text(
                    content,
                    style: SwarajTypography.body(fontSize: 14, color: SwarajColors.slate),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text('CLOSE',
                        style: SwarajTypography.mono(
                            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _termsContent = '''
TERMS OF SERVICE
Effective Date: June 2026

1. ACCEPTANCE
By registering on Swaraj, you confirm that you have read, understood, and agree to these Terms of Service. If you do not agree, please do not use the application.

2. ELIGIBILITY
Swaraj is designed for students aged 13 and above. By registering, you confirm that you meet this age requirement. Use by children under 13 is not permitted without parental consent.

3. EDUCATIONAL PURPOSE
Swaraj is a non-commercial civic education platform built under MY Bharat. All content — lessons, quizzes, daily challenges, debates, and AI explanations — is intended solely for educational purposes and is presented in a strictly non-partisan manner. Swaraj does not endorse any political party or ideology.

4. USER CONDUCT
You agree not to:
• Misuse the AI assistant for purposes other than civic education
• Post or share content that is illegal, offensive, communally divisive, or politically biased
• Impersonate any person, institution, or organisation
• Attempt to access, tamper with, or disrupt the platform's systems or data
• Use the platform for commercial purposes

5. INTELLECTUAL PROPERTY
All content on Swaraj — including lessons, quizzes, graphics, and design — is the intellectual property of Swaraj. You may not reproduce, distribute, or create derivative works without explicit written permission.

6. CERTIFICATES & ACHIEVEMENTS
Digital certificates and badges issued by Swaraj are based on platform performance and are for educational recognition only. They do not constitute formal academic credentials.

7. ACCOUNT SUSPENSION
Swaraj reserves the right to suspend or permanently terminate accounts that violate these terms, without prior notice.

8. DISCLAIMER
All content on Swaraj is for educational purposes only. It does not constitute legal, political, or professional advice. While we strive for factual accuracy, errors may occur and should be independently verified.

9. CHANGES TO TERMS
We may update these Terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.

10. GOVERNING LAW
These Terms are governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in India.

Contact: swaraj.org.in@gmail.com''';

  static const String _privacyContent = '''
PRIVACY POLICY
Effective Date: June 2026

1. INFORMATION WE COLLECT
When you use Swaraj, we collect:
• Email address and mobile number — for secure OTP-based authentication
• Name, date of birth, grade, and school/institution — for personalisation and leaderboards
• Learning progress, quiz scores, daily challenge results, and debate responses — to track your civic journey
• App language preference (English / Hindi)

We do not collect payment information. Swaraj is free to use.

2. HOW WE USE YOUR DATA
Your data is used to:
• Verify your identity via One-Time Password (OTP)
• Personalise your civic learning experience
• Display school-level leaderboards (visible only to students of the same school)
• Issue digital certificates of learning completion
• Calculate and display your Political IQ score
• Maintain streaks and achievement badges
• Improve platform content and features

3. AI ASSISTANT — TARQA AI
When you use the Swaraj AI Assistant, your typed question is sent to TARQA AI (tarqaai.com) for processing. We do not include any personally identifiable information (name, phone number, email, or school) in AI queries. AI responses are generated externally and are not stored permanently.

4. DATA SHARING
We do not sell, rent, or trade your personal data to any third party. We may share:
• Anonymised, aggregated statistics with educational or government partners for civic engagement research
• Data with Supabase (our infrastructure provider) under strict data processing agreements

5. DATA SECURITY
All data is encrypted in transit using HTTPS/TLS. User data is stored on Supabase's secure, SOC 2-compliant cloud infrastructure hosted in the Asia-Pacific region.

6. YOUR RIGHTS
Under Indian law and global best practices, you have the right to:
• Access a copy of your personal data
• Correct inaccurate information
• Request deletion of your account and associated data
• Withdraw consent at any time

To exercise these rights, email us at: swaraj.org.in@gmail.com

7. DATA RETENTION
We retain your data for as long as your account remains active. Upon account deletion:
• Personal data (name, email, phone) is removed within 30 days
• Anonymised learning statistics may be retained for platform improvement

8. CHILDREN'S PRIVACY
Swaraj is not intended for children under 13. We do not knowingly collect data from children under 13 without verifiable parental consent. If you believe we have collected such data, contact us immediately.

9. COMPLIANCE
Swaraj complies with:
• India's Information Technology Act, 2000
• The Digital Personal Data Protection Act (DPDPA), 2023
• Applicable data protection principles

10. CHANGES TO THIS POLICY
We may update this Privacy Policy. We will notify you of significant changes through the app.

Contact for privacy concerns: swaraj.org.in@gmail.com''';

  Future<void> _submit() async {
    if (!_isButtonEnabled || _isLoading) return;
    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendOtp(email: email, phone: phone);
      if (!mounted) return;
      Navigator.pushNamed(context, '/otp', arguments: email);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^.*?: '), '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SwarajColors.navy,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: SwarajColors.navy.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield, size: 22, color: SwarajColors.saffron),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SWARAJ',
                    style: SwarajTypography.headline(
                        fontSize: 22, fontWeight: FontWeight.w800, color: SwarajColors.navy),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Heading
              Text(
                'Welcome',
                style: SwarajTypography.headline(
                    fontSize: 40, fontWeight: FontWeight.w800, color: SwarajColors.navy),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your email and phone\nto continue your civic journey.',
                style: SwarajTypography.body(
                    fontSize: 15, color: SwarajColors.slate),
              ),

              const SizedBox(height: 40),

              // Email field
              Text('EMAIL ADDRESS',
                  style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.slateLight)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                style: SwarajTypography.body(
                    fontSize: 15, fontWeight: FontWeight.w600, color: SwarajColors.navy),
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  hintStyle: SwarajTypography.body(color: SwarajColors.outline),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18,
                      color: SwarajColors.slateLight),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: SwarajColors.navy.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SwarajColors.saffron, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone field
              Text('PHONE NUMBER',
                  style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.slateLight)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '+91',
                          style: SwarajTypography.mono(
                              fontSize: 14, fontWeight: FontWeight.bold, color: SwarajColors.navy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !_isLoading,
                      style: SwarajTypography.body(
                          fontSize: 15, fontWeight: FontWeight.w600, color: SwarajColors.navy),
                      decoration: InputDecoration(
                        hintText: '10-digit mobile number',
                        hintStyle: SwarajTypography.body(color: SwarajColors.outline),
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: SwarajColors.navy.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: SwarajColors.saffron, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: SwarajColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: SwarajColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: SwarajTypography.body(fontSize: 13, color: SwarajColors.error)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Terms checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (v) {
                        _termsAccepted = v ?? false;
                        _validate();
                      },
                      activeColor: SwarajColors.navy,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      side: BorderSide(
                        color: _termsAccepted ? SwarajColors.navy : SwarajColors.outline,
                        width: 1.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text.rich(
                        TextSpan(
                          style: SwarajTypography.body(fontSize: 13, color: SwarajColors.slate),
                          children: [
                            const TextSpan(text: 'I have read and agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: SwarajTypography.body(
                                fontSize: 13,
                                color: SwarajColors.saffron,
                                fontWeight: FontWeight.w600,
                              ).copyWith(decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _showPolicySheet('Terms of Service', _termsContent),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: SwarajTypography.body(
                                fontSize: 13,
                                color: SwarajColors.saffron,
                                fontWeight: FontWeight.w600,
                              ).copyWith(decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _showPolicySheet('Privacy Policy', _privacyContent),
                            ),
                            const TextSpan(text: ' of Swaraj.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.saffron,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: SwarajColors.saffron.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('SEND OTP',
                                style: SwarajTypography.mono(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // MY Bharat note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: SwarajColors.navy.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.07)),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '🇮🇳  '),
                      TextSpan(
                        text: 'Powered by MY Bharat ',
                        style: SwarajTypography.mono(
                            fontSize: 11, fontWeight: FontWeight.bold, color: SwarajColors.saffron),
                      ),
                      TextSpan(
                        text: '— mobilising 50 lakh+ young citizens.',
                        style: SwarajTypography.body(fontSize: 12, color: SwarajColors.slateLight),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
