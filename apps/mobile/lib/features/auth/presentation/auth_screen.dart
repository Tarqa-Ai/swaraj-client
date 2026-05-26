import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/auth_repository.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool sent = false;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('SWARAJ', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Build your civic confidence through lessons, debates, quizzes, and challenges.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number')),
              if (sent) ...[
                const SizedBox(height: 12),
                TextField(controller: otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
              ],
              if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: loading ? null : _submit,
                child: Text(loading ? 'Please wait...' : sent ? 'Verify OTP' : 'Send OTP'),
              ),
              TextButton(onPressed: () => context.go('/onboarding'), child: const Text('Continue to onboarding')),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      if (!sent) {
        await repo.sendOtp(phone.text.trim());
        setState(() => sent = true);
      } else {
        await repo.verifyOtp(phone: phone.text.trim(), code: otp.text.trim());
        if (mounted) context.go('/dashboard');
      }
    } catch (err) {
      setState(() => error = err.toString());
    } finally {
      setState(() => loading = false);
    }
  }
}
