import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/state_views.dart';

final moduleDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) => ref.read(apiClientProvider).get('/modules/$id'));

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
          final lessons = module['lessons'] as List<dynamic>;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(module['titleEn'] as String, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(module['descriptionEn'] as String),
              const SizedBox(height: 20),
              for (final item in lessons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LessonCard(lesson: item as Map<String, dynamic>),
                ),
            ],
          );
        },
      ),
    );
  }
}

class LessonCard extends ConsumerWidget {
  const LessonCard({required this.lesson, super.key});
  final Map<String, dynamic> lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson['titleEn'] as String, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(lesson['bodyEn'] as String),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () async {
                await ref.read(apiClientProvider).post('/lessons/${lesson['id']}/complete', {});
                ref.invalidate(moduleDetailProvider);
              },
              child: Text((lesson['completed'] as bool? ?? false) ? 'Completed' : 'Mark complete'),
            ),
          ],
        ),
      ),
    );
  }
}
