import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/state_views.dart';
import '../data/learning_repository.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({required this.moduleId, required this.lessonId, super.key});

  final String moduleId;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _marking = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(moduleDetailProvider(widget.moduleId));
    return detail.when(
      loading: () => const Scaffold(body: LoadingSkeleton()),
      error: (_, __) => const Scaffold(
        body: EmptyState(title: 'Lesson unavailable', body: 'Go back and try again.'),
      ),
      data: (module) {
        final lessons = (module['lessons'] as List<dynamic>).cast<Map<String, dynamic>>();
        final lesson = lessons.where((l) => l['id'] == widget.lessonId).firstOrNull;

        if (lesson == null) {
          return const Scaffold(
            body: EmptyState(title: 'Lesson not found', body: 'This lesson may have been removed.'),
          );
        }

        final completed = lesson['completed'] as bool? ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(lesson['titleEn'] as String? ?? 'Lesson'),
            actions: [
              if (completed)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                lesson['titleEn'] as String? ?? '',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                lesson['bodyEn'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              if (!completed)
                FilledButton(
                  onPressed: _marking ? null : _markComplete,
                  child: Text(_marking ? 'Saving...' : 'Mark as complete'),
                )
              else
                const FilledButton.tonal(onPressed: null, child: Text('Completed')),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markComplete() async {
    setState(() {
      _marking = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).post('/lessons/${widget.lessonId}/complete', {});
      ref.invalidate(moduleDetailProvider(widget.moduleId));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }
}
