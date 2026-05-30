import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../data/learning_repository.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({required this.moduleId, super.key});
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(moduleDetailProvider(moduleId));
    return Scaffold(
      appBar: AppBar(title: const Text('Module')),
      body: detail.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Module unavailable', body: 'Try another module.'),
        data: (module) {
          final lessons = (module['lessons'] as List<dynamic>).cast<Map<String, dynamic>>();
          final quizzes = (module['quizzes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(module['titleEn'] as String, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(module['descriptionEn'] as String),
              const SizedBox(height: 20),
              for (final lesson in lessons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LessonTile(lesson: lesson, moduleId: moduleId),
                ),
              for (final quiz in quizzes)
                Card(
                  child: ListTile(
                    title: Text(quiz['titleEn'] as String),
                    subtitle: Text('${(quiz['questions'] as List<dynamic>? ?? []).length} questions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/quiz/${quiz['id']}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.moduleId});

  final Map<String, dynamic> lesson;
  final String moduleId;

  @override
  Widget build(BuildContext context) {
    final completed = lesson['completed'] as bool? ?? false;
    return Card(
      child: ListTile(
        leading: Icon(completed ? Icons.check_circle : Icons.menu_book, color: completed ? Colors.green : null),
        title: Text(lesson['titleEn'] as String),
        subtitle: Text(completed ? 'Completed' : 'Tap to read'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/modules/$moduleId/lessons/${lesson['id']}'),
      ),
    );
  }
}
