import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
              Text('Learn democracy by doing', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Text('Choose Hindi or English, join your school, and complete civic missions designed for Grades 9-12.'),
              const SizedBox(height: 24),
              const Wrap(
                spacing: 12,
                children: [
                  Chip(label: Text('English')),
                  Chip(label: Text('हिंदी')),
                  Chip(label: Text('Grade 9-12')),
                  Chip(label: Text('Rajasthan schools')),
                ],
              ),
              const Spacer(),
              FilledButton(onPressed: () => context.go('/dashboard'), child: const Text('Start learning')),
            ],
          ),
        ),
      ),
    );
  }
}
