import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('School leaderboard')),
      body: leaderboard.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Leaderboard unavailable', body: 'Join a school to see ranks.'),
        data: (data) {
          final items = data['items'] as List<dynamic>;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemBuilder: (_, index) {
              final user = items[index] as Map<String, dynamic>;
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                leading: CircleAvatar(child: Text('${user['rank']}')),
                title: Text((user['name'] as String?) ?? 'Student'),
                subtitle: Text('Streak ${user['streakCount']}'),
                trailing: Text('${user['politicalIq']} IQ'),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
