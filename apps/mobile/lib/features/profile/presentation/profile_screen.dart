import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Profile unavailable', body: 'Sign in again to refresh your session.'),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(radius: 42, child: Text(((data['name'] as String?) ?? 'S').substring(0, 1))),
            const SizedBox(height: 16),
            Center(child: Text((data['name'] as String?) ?? 'Student', style: Theme.of(context).textTheme.headlineSmall)),
            Center(child: Text('${data['politicalIq']} Political IQ • ${data['level']}')),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => context.go('/certificate'), child: const Text('View certificate status')),
          ],
        ),
      ),
    );
  }
}
