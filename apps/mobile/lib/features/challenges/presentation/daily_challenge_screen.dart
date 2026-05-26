import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_repository.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(dailyChallengeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily civic challenge')),
      body: challenge.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Challenge unavailable', body: 'A new challenge will appear soon.'),
        data: (data) {
          final questions = data['questions'] as List<dynamic>;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('${data['category']}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final question in questions)
                Card(
                  child: ListTile(
                    title: Text((question as Map<String, dynamic>)['promptEn'] as String),
                    subtitle: Text((question['options'] as List<dynamic>).join(' • ')),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
