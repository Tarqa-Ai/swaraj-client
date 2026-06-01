import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isButtonEnabled = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(_validateOTP);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _validateOTP() {
    bool allFilled = true;
    for (var c in _controllers) {
      if (c.text.isEmpty) {
        allFilled = false;
        break;
      }
    }
    setState(() {
      _isButtonEnabled = allFilled;
    });
  }

  void _resendOTP() {
    setState(() {
      _secondsRemaining = 30;
    });
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'OTP resent successfully',
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitOTP() {
    if (_isButtonEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification successful',
            style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: SwarajColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        '/setup',
        arguments: {'phoneNumber': widget.phoneNumber},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneDisplay = widget.phoneNumber.length == 10
        ? '+91 ${widget.phoneNumber.substring(0, 5)} ${widget.phoneNumber.substring(5, 10)}'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: SwarajColors.navy),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify OTP',
                style: SwarajTypography.headline(fontSize: 32),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: "We've sent a 4-digit code to ",
                  style: SwarajTypography.body(),
                  children: [
                    TextSpan(
                      text: phoneDisplay,
                      style: SwarajTypography.body(
                          fontWeight: FontWeight.bold,
                          color: SwarajColors.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 64,
                    height: 68,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: SwarajTypography.headline(
                          fontSize: 28, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: SwarajColors.navy.withValues(alpha: 0.1),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: SwarajColors.saffron, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        _validateOTP();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Center(
                child: _secondsRemaining > 0
                    ? RichText(
                        text: TextSpan(
                          text: 'Resend code in ',
                          style: SwarajTypography.body(fontSize: 14),
                          children: [
                            TextSpan(
                              text: '${_secondsRemaining}s',
                              style: SwarajTypography.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: SwarajColors.saffron),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          'Resend Code',
                          style: SwarajTypography.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.saffron,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _submitOTP : null,
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
                        'VERIFY & CONTINUE',
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
        ),
      ),
    );
  }
}
