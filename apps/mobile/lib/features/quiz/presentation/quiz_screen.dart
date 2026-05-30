import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quiz_repository.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({required this.quizId, super.key});
  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider(quizId));
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: state == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(state.quiz['titleEn'] as String? ?? 'Quiz', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                for (final question in (state.quiz['questions'] as List<dynamic>? ?? []))
                  _QuestionCard(
                    question: question as Map<String, dynamic>,
                    selected: state.answers[question['id']],
                    disabled: state.result != null,
                    result: _resultFor(state.result, question['id'] as String),
                    onSelected: (answer) => ref.read(quizControllerProvider(quizId).notifier).select(question['id'] as String, answer),
                  ),
                if (state.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(state.error!, style: const TextStyle(color: Colors.red))),
                if (state.result != null) _ScoreCard(result: state.result!),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.submitting || state.result != null ? null : () => ref.read(quizControllerProvider(quizId).notifier).submit(),
                  child: Text(state.submitting ? 'Submitting...' : 'Submit quiz'),
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
  final dynamic selected;
  final bool disabled;
  final Map<String, dynamic>? result;
  final ValueChanged<dynamic> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = question['options'] as List<dynamic>? ?? [];
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
                leading: Icon(selected == option ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text(option.toString()),
                onTap: disabled ? null : () => onSelected(option),
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

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Score: ${result['score']}% • ${result['correct']}/${result['total']} correct • IQ earned: ${result['iqEarned']}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
