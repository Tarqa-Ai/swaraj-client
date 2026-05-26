import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/swaraj_card.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SWARAJ')),
      body: dashboard.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Unable to load dashboard', body: 'Check your connection or sign in again.'),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your civic journey', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            SwarajCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Metric(label: 'Political IQ', value: '${data['politicalIq'] ?? 0}'),
                  _Metric(label: 'Streak', value: '${data['streakCount'] ?? 0}'),
                  _Metric(label: 'Rank', value: '#${data['leaderboardRank'] ?? '-'}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ActionTile(title: 'Resume learning', subtitle: 'Complete bite-sized lessons', onTap: () => context.go('/modules')),
            _ActionTile(title: 'Daily civic challenge', subtitle: 'Answer 3 questions today', onTap: () => context.go('/challenge')),
            _ActionTile(title: 'Debate arena', subtitle: 'Practice balanced civic thinking', onTap: () => context.go('/debate')),
            _ActionTile(title: 'Explain simply', subtitle: 'Ask about Article 21, MLA, elections', onTap: () => context.go('/ai')),
            _ActionTile(title: 'Leaderboard', subtitle: 'See your school ranking', onTap: () => context.go('/leaderboard')),
            _ActionTile(title: 'Profile and certificate', subtitle: 'Badges, progress, certificate', onTap: () => context.go('/profile')),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: Theme.of(context).textTheme.headlineSmall), Text(label)]);
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.title, required this.subtitle, required this.onTap});
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
