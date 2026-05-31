import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../data/onboarding_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final name = TextEditingController();
  String language = 'en';
  int grade = 9;
  String? schoolId;
  String? error;

  @override
  Widget build(BuildContext context) {
    final schools = ref.watch(schoolsProvider);
    final saving = ref.watch(onboardingControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Learn democracy by doing', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Text('Choose Hindi or English, join your school, and complete civic missions designed for Grades 9-12.'),
              const SizedBox(height: 24),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'hi', label: Text('हिंदी')),
                ],
                selected: {language},
                onSelectionChanged: (value) => setState(() => language = value.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: grade,
                decoration: const InputDecoration(labelText: 'Grade'),
                items: [9, 10, 11, 12].map((item) => DropdownMenuItem(value: item, child: Text('Grade $item'))).toList(),
                onChanged: (value) => setState(() => grade = value ?? grade),
              ),
              const SizedBox(height: 12),
              schools.when(
                loading: () => const LoadingSkeleton(),
                error: (_, __) => const EmptyState(title: 'Schools unavailable', body: 'Try again when your connection is active.'),
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: schoolId,
                  decoration: const InputDecoration(labelText: 'School'),
                  items: items
                      .map((item) => item as Map<String, dynamic>)
                      .map((school) => DropdownMenuItem(value: school['id'] as String, child: Text(school['name'] as String)))
                      .toList(),
                  onChanged: (value) => setState(() => schoolId = value),
                ),
              ),
              if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
              const Spacer(),
              FilledButton(onPressed: saving ? null : _save, child: Text(saving ? 'Saving...' : 'Start learning')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final selectedSchool = schoolId;
    if (name.text.trim().length < 2 || selectedSchool == null) {
      setState(() => error = 'Enter your name and select your school.');
      return;
    }
    try {
      await ref.read(onboardingControllerProvider.notifier).saveProfile(
            name: name.text.trim(),
            language: language,
            grade: grade,
            schoolId: selectedSchool,
          );
      if (mounted) context.go('/dashboard');
    } catch (err) {
      setState(() => error = err.toString());
    }
  }
}
