import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_repository.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(modulesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Learning modules')),
      body: modules.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Modules unavailable', body: 'Try again later.'),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemBuilder: (_, index) {
            final module = items[index] as Map<String, dynamic>;
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(module['titleEn'] as String),
              subtitle: Text('${module['lessonCount']} lessons • ${module['estimatedMinutes']} min'),
              trailing: Icon((module['completed'] as bool? ?? false) ? Icons.check_circle : Icons.chevron_right),
              onTap: () => context.go('/modules/${module['id']}'),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        ),
      ),
    );
  }
}
