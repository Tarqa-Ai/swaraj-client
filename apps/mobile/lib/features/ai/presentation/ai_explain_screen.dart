import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

class AiExplainScreen extends ConsumerStatefulWidget {
  const AiExplainScreen({super.key});

  @override
  ConsumerState<AiExplainScreen> createState() => _AiExplainScreenState();
}

class _AiExplainScreenState extends ConsumerState<AiExplainScreen> {
  final question = TextEditingController(text: 'What is Article 21?');
  String? answer;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explain simply')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: question, decoration: const InputDecoration(labelText: 'Ask one civic concept')),
          const SizedBox(height: 12),
          FilledButton(onPressed: loading ? null : _explain, child: Text(loading ? 'Explaining...' : 'Explain')),
          if (answer != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Text(answer!))),
            ),
        ],
      ),
    );
  }

  Future<void> _explain() async {
    setState(() => loading = true);
    final result = await ref.read(apiClientProvider).post<Map<String, dynamic>>('/ai/explain', {'question': question.text, 'language': 'en'});
    setState(() {
      answer = result['explanation'] as String;
      loading = false;
    });
  }
}
