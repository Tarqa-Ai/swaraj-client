import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

class _AiState {
  const _AiState({this.answer, this.loading = false, this.error});
  final String? answer;
  final bool loading;
  final String? error;

  _AiState copyWith({String? answer, bool? loading, String? error}) {
    return _AiState(answer: answer ?? this.answer, loading: loading ?? this.loading, error: error);
  }
}

class _AiController extends StateNotifier<_AiState> {
  _AiController(this._api) : super(const _AiState());

  final ApiClient _api;

  Future<void> explain(String question, String language) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await _api.post<Map<String, dynamic>>('/ai/explain', {'question': question, 'language': language});
      state = state.copyWith(loading: false, answer: result['explanation'] as String?);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final _aiControllerProvider = StateNotifierProvider.autoDispose<_AiController, _AiState>(
  (ref) => _AiController(ref.read(apiClientProvider)),
);

class AiExplainScreen extends ConsumerStatefulWidget {
  const AiExplainScreen({super.key});

  @override
  ConsumerState<AiExplainScreen> createState() => _AiExplainScreenState();
}

class _AiExplainScreenState extends ConsumerState<AiExplainScreen> {
  final _question = TextEditingController(text: 'What is Article 21?');
  String _language = 'en';

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_aiControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explain simply')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _question,
            enabled: !state.loading,
            decoration: const InputDecoration(labelText: 'Ask one civic concept'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English')),
              ButtonSegment(value: 'hi', label: Text('हिंदी')),
            ],
            selected: {_language},
            onSelectionChanged: state.loading ? null : (value) => setState(() => _language = value.first),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading ? null : () => ref.read(_aiControllerProvider.notifier).explain(_question.text, _language),
            child: Text(state.loading ? 'Explaining...' : 'Explain'),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(state.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (state.answer != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(state.answer!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
