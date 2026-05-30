import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final currentDebateProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.read(apiClientProvider).get('/debate/current'),
);

class DebateSubmitState {
  const DebateSubmitState({this.submitting = false, this.submitted = false, this.error});

  final bool submitting;
  final bool submitted;
  final String? error;

  DebateSubmitState copyWith({bool? submitting, bool? submitted, String? error}) {
    return DebateSubmitState(
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
      error: error,
    );
  }
}

class DebateController extends StateNotifier<DebateSubmitState> {
  DebateController(this._api) : super(const DebateSubmitState());

  final ApiClient _api;

  Future<void> respond({required String debateId, required String side, required String reflection}) async {
    state = state.copyWith(submitting: true, error: null);
    try {
      await _api.post('/debate/respond', {'debateId': debateId, 'side': side, 'reflection': reflection});
      state = state.copyWith(submitting: false, submitted: true);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }
}

final debateControllerProvider = StateNotifierProvider.autoDispose<DebateController, DebateSubmitState>(
  (ref) => DebateController(ref.read(apiClientProvider)),
);
