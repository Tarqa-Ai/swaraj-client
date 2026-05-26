import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/widgets/state_views.dart';

final certificateStatusProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/certificate/status'));

class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(certificateStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Certified Young Civic Leader')),
      body: status.when(
        loading: () => const LoadingSkeleton(),
        error: (_, __) => const EmptyState(title: 'Certificate unavailable', body: 'Complete modules, a challenge, and a debate.'),
        data: (data) => Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['eligible'] == true ? 'You are eligible' : 'Keep learning', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Modules: ${data['completedModules']}/${data['totalModules']} • Challenges: ${data['challenges']} • Debates: ${data['debates']}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: data['eligible'] == true
                        ? () async {
                            await ref.read(apiClientProvider).get('/certificate/download');
                            ref.invalidate(certificateStatusProvider);
                          }
                        : null,
                    child: const Text('Generate certificate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
