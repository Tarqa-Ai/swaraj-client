import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({required this.quizId, super.key});
  final String quizId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz engine', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Text('MCQ, true/false, and match-column submissions are supported by the API. Lesson module screens expose quiz metadata for a richer player flow.'),
          ],
        ),
      ),
    );
  }
}
