import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../data/daily_challenge_repository.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyChallengeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily civic challenge')),
      body: state.loading
          ? const LoadingSkeleton()
          : state.challenge == null
              ? const EmptyState(title: 'Challenge unavailable', body: 'A new challenge will appear soon.')
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('${state.challenge!['category']}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    for (final question in state.challenge!['questions'] as List<dynamic>)
                      _QuestionCard(
                        question: question as Map<String, dynamic>,
                        selected: state.answers[question['id']],
                        disabled: state.result != null || state.challenge!['completed'] == true,
                        result: _resultFor(state.result, question['id'] as String),
                        onSelected: (answer) => ref.read(dailyChallengeControllerProvider.notifier).select(question['id'] as String, answer),
                      ),
                    if (state.challenge!['completed'] == true && state.result == null)
                      const EmptyState(title: 'Already submitted', body: 'Come back tomorrow for a new challenge.'),
                    if (state.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(state.error!, style: const TextStyle(color: Colors.red))),
                    if (state.result != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Score: ${state.result!['score']}% • IQ awarded: ${state.result!['iqEarned']} • Streak: ${state.result!['streakCount']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: state.submitting || state.result != null || state.challenge!['completed'] == true
                          ? null
                          : () => ref.read(dailyChallengeControllerProvider.notifier).submit(),
                      child: Text(state.submitting ? 'Submitting...' : 'Submit challenge'),
                    ),
                  ],
                ),
    );
  }
}

Map<String, dynamic>? _resultFor(Map<String, dynamic>? result, String questionId) {
  final results = result?['results'] as List<dynamic>?;
  if (results == null) return null;
  for (final item in results) {
    final map = item as Map<String, dynamic>;
    if (map['questionId'] == questionId) return map;
  }
  return null;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.selected, required this.disabled, required this.onSelected, this.result});

  final Map<String, dynamic> question;
  final String? selected;
  final bool disabled;
  final Map<String, dynamic>? result;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = question['options'] as List<dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['promptEn'] as String, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(selected == option.toString() ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(option.toString()),
                onTap: disabled ? null : () => onSelected(option.toString()),
              ),
            if (result != null)
              Text(
                '${result!['correct'] == true ? 'Correct' : 'Correct answer: ${result!['answer']}'}\n${result!['explanationEn']}',
                style: TextStyle(color: result!['correct'] == true ? Colors.green : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
