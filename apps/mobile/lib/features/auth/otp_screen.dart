import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/storage/session_store.dart';
import 'data/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _error;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < _otpLength; i++) {
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
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
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
    final allFilled = _controllers.every((c) => c.text.isNotEmpty);
    setState(() {
      _isButtonEnabled = allFilled;
      _error = null;
    });
  }
// Nice
  Future<void> _resendOTP() async {
    setState(() => _error = null);
    try {
      final phone = await ref.read(sessionStoreProvider).getPhone() ?? '';
      await ref.read(authRepositoryProvider).sendOtp(email: widget.email, phone: phone);
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP resent to ${widget.email}',
              style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
          backgroundColor: SwarajColors.navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^.*?: '), '');
      });
    }
  }

  Future<void> _submitOTP() async {
    if (!_isButtonEnabled || _isLoading) return;
    final code = _controllers.map((c) => c.text).join();
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = await ref.read(authRepositoryProvider).verifyOtp(
            email: widget.email,
            code: code,
          );
      final phone = await ref.read(sessionStoreProvider).getPhone() ?? '';
      if (!mounted) return;
      final isNewUser = user['onboardingCompletedAt'] == null;
      if (isNewUser) {
        Navigator.pushReplacementNamed(
          context,
          '/setup',
          arguments: {'phoneNumber': phone},
        );
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: SwarajColors.navy),
                style: IconButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 24),
              Text('Verify OTP', style: SwarajTypography.headline(fontSize: 32)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: "We've sent a 6-digit code to ",
                  style: SwarajTypography.body(),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: SwarajTypography.body(
                          fontWeight: FontWeight.bold, color: SwarajColors.navy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: 44,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      enabled: !_isLoading,
                      style: SwarajTypography.headline(fontSize: 24, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: SwarajColors.navy.withValues(alpha: 0.1), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: SwarajColors.saffron, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < _otpLength - 1) {
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
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: SwarajTypography.body(fontSize: 13, color: Colors.red.shade700)),
              ],
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
                        onPressed: _isLoading ? null : _resendOTP,
                        child: Text('Resend Code',
                            style: SwarajTypography.mono(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: SwarajColors.saffron)),
                      ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading ? _submitOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: SwarajColors.navy.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('VERIFY & CONTINUE',
                                style: SwarajTypography.mono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
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
