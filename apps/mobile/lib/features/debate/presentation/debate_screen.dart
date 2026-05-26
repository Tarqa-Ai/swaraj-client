import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_repository.dart';

class DebateScreen extends ConsumerStatefulWidget {
  const DebateScreen({super.key});

  @override
  ConsumerState<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends ConsumerState<DebateScreen> {
  String side = 'FOR';
  final reflection = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final debate = ref.watch(currentDebateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Debate arena')),
      body: debate.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'No active debate', body: 'Your teacher can publish one from the admin panel.'),
        data: (data) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(data['topicEn'] as String, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Card(child: ListTile(title: const Text('FOR'), subtitle: Text(data['forSummaryEn'] as String))),
            Card(child: ListTile(title: const Text('AGAINST'), subtitle: Text(data['againstSummaryEn'] as String))),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'FOR', label: Text('For')), ButtonSegment(value: 'AGAINST', label: Text('Against'))],
              selected: {side},
              onSelectionChanged: (value) => setState(() => side = value.first),
            ),
            const SizedBox(height: 12),
            TextField(controller: reflection, minLines: 4, maxLines: 6, decoration: const InputDecoration(labelText: 'Your reflection')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref.read(apiClientProvider).post('/debate/respond', {'debateId': data['id'], 'side': side, 'reflection': reflection.text});
                ref.invalidate(currentDebateProvider);
              },
              child: const Text('Submit reflection'),
            ),
          ],
        ),
      ),
    );
  }
}
