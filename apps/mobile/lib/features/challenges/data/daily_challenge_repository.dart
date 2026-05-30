import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final dailyChallengeRepositoryProvider = Provider<DailyChallengeRepository>((ref) => DailyChallengeRepository(ref.read(apiClientProvider)));
final dailyChallengeControllerProvider = StateNotifierProvider<DailyChallengeController, DailyChallengeState>(
  (ref) => DailyChallengeController(ref.read(dailyChallengeRepositoryProvider)),
);

class DailyChallengeRepository {
  DailyChallengeRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> current() => _api.get<Map<String, dynamic>>('/daily-challenge');

  Future<Map<String, dynamic>> submit({required String challengeId, required Map<String, String> answers}) {
    return _api.post<Map<String, dynamic>>('/daily-challenge/submit', {'challengeId': challengeId, 'answers': answers});
  }
}

class DailyChallengeState {
  const DailyChallengeState({this.challenge, this.answers = const {}, this.result, this.loading = true, this.submitting = false, this.error});

  final Map<String, dynamic>? challenge;
  final Map<String, String> answers;
  final Map<String, dynamic>? result;
  final bool loading;
  final bool submitting;
  final String? error;

  DailyChallengeState copyWith({
    Map<String, dynamic>? challenge,
    Map<String, String>? answers,
    Map<String, dynamic>? result,
    bool? loading,
    bool? submitting,
    String? error,
  }) {
    return DailyChallengeState(
      challenge: challenge ?? this.challenge,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }
}

class DailyChallengeController extends StateNotifier<DailyChallengeState> {
  DailyChallengeController(this._repository) : super(const DailyChallengeState()) {
    load();
  }

  final DailyChallengeRepository _repository;

  Future<void> load() async {
    try {
      final challenge = await _repository.current();
      state = DailyChallengeState(challenge: challenge, loading: false);
    } catch (err) {
      state = DailyChallengeState(loading: false, error: err.toString());
    }
  }

  void select(String questionId, String answer) {
    if (state.result != null) return;
    state = state.copyWith(answers: {...state.answers, questionId: answer});
  }

  Future<void> submit() async {
    final challenge = state.challenge;
    if (challenge == null) return;
    state = state.copyWith(submitting: true, error: null);
    try {
      final result = await _repository.submit(challengeId: challenge['id'] as String, answers: state.answers);
      state = state.copyWith(result: result, submitting: false, error: null);
    } catch (err) {
      state = state.copyWith(submitting: false, error: err.toString());
    }
  }
}
