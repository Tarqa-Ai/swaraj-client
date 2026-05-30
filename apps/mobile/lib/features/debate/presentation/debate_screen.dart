import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../data/debate_repository.dart';

class DebateScreen extends ConsumerStatefulWidget {
  const DebateScreen({super.key});

  @override
  ConsumerState<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends ConsumerState<DebateScreen> {
  String _side = 'FOR';
  final _reflection = TextEditingController();

  @override
  void dispose() {
    _reflection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debate = ref.watch(currentDebateProvider);
    final submitState = ref.watch(debateControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debate arena')),
      body: debate.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'No active debate', body: 'Your teacher can publish one from the admin panel.'),
        data: (data) {
          final responded = data['responded'] as bool? ?? false;

          if (submitState.submitted || responded) {
            return const EmptyState(
              title: 'Response submitted',
              body: 'Your reflection has been recorded. Check back for the next debate.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(data['topicEn'] as String, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Card(child: ListTile(title: const Text('FOR'), subtitle: Text(data['forSummaryEn'] as String))),
              Card(child: ListTile(title: const Text('AGAINST'), subtitle: Text(data['againstSummaryEn'] as String))),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'FOR', label: Text('For')),
                  ButtonSegment(value: 'AGAINST', label: Text('Against')),
                ],
                selected: {_side},
                onSelectionChanged: submitState.submitting ? null : (value) => setState(() => _side = value.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reflection,
                minLines: 4,
                maxLines: 6,
                enabled: !submitState.submitting,
                decoration: const InputDecoration(labelText: 'Your reflection'),
              ),
              if (submitState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(submitState.error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: submitState.submitting
                    ? null
                    : () => ref.read(debateControllerProvider.notifier).respond(
                          debateId: data['id'] as String,
                          side: _side,
                          reflection: _reflection.text,
                        ),
                child: Text(submitState.submitting ? 'Submitting...' : 'Submit reflection'),
              ),
            ],
          );
        },
      ),
    );
  }
}
