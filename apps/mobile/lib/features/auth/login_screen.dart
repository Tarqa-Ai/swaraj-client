import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final text = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _isButtonEnabled = text.length == 10;
    });
  }

  void _submitLogin() {
    if (_isButtonEnabled) {
      final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: phone,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SwarajColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 20,
                      color: SwarajColors.saffron,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SWARAJ',
                    style: SwarajTypography.headline(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                'Welcome Back',
                style: SwarajTypography.headline(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your phone number to continue your civic education journey.',
                style: SwarajTypography.body(),
              ),
              const SizedBox(height: 12),
              Text(
                '"Answering the PM\'s call to engage India\'s youth in nation-building — Viksit Bharat @ 2047"',
                style: SwarajTypography.mono(
                  fontSize: 10,
                  color: SwarajColors.saffron,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 36),
              Text(
                'PHONE NUMBER',
                style: SwarajTypography.mono(fontSize: 11),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      color: SwarajColors.navy.withValues(alpha: 0.04),
                      border: Border.all(
                          color: SwarajColors.navy.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 16,
                          color: SwarajColors.navy,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+91',
                          style: SwarajTypography.mono(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.navy,
                          ),
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
                      style: SwarajTypography.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: SwarajColors.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter 10-digit number',
                        hintStyle:
                            SwarajTypography.body(color: SwarajColors.outline),
                        counterText: '',
                        filled: true,
                        fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: SwarajColors.navy.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: SwarajColors.saffron, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _submitLogin : null,
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
              const SizedBox(height: 48),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: SwarajTypography.body(
                        fontSize: 12, color: SwarajColors.slateLight),
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
