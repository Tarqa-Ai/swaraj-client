import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) => QuizRepository(ref.read(apiClientProvider)));
final quizProvider = FutureProvider.family<QuizState, String>((ref, quizId) async {
  final quiz = await ref.read(quizRepositoryProvider).fetchQuiz(quizId);
  return QuizState(quiz: quiz);
});

class QuizRepository {
  QuizRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchQuiz(String quizId) async {
    final modules = await _api.get<List<dynamic>>('/modules');
    for (final module in modules) {
      final quizzes = (module as Map<String, dynamic>)['quizzes'] as List<dynamic>? ?? [];
      for (final quiz in quizzes) {
        final quizMap = quiz as Map<String, dynamic>;
        if (quizMap['id'] == quizId) return quizMap;
      }
    }
    throw StateError('Quiz not found');
  }

  Future<Map<String, dynamic>> submit({required String quizId, required Map<String, dynamic> answers}) {
    return _api.post<Map<String, dynamic>>('/quiz/submit', {'quizId': quizId, 'answers': answers});
  }
}

class QuizState {
  const QuizState({required this.quiz, this.answers = const {}, this.result, this.submitting = false, this.error});

  final Map<String, dynamic> quiz;
  final Map<String, dynamic> answers;
  final Map<String, dynamic>? result;
  final bool submitting;
  final String? error;

  QuizState copyWith({
    Map<String, dynamic>? quiz,
    Map<String, dynamic>? answers,
    Map<String, dynamic>? result,
    bool? submitting,
    String? error,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
      result: result ?? this.result,
      submitting: submitting ?? this.submitting,
      error: error,
    );
  }
}

final quizControllerProvider = StateNotifierProvider.family<QuizController, QuizState?, String>((ref, quizId) {
  return QuizController(ref.read(quizRepositoryProvider), quizId);
});

class QuizController extends StateNotifier<QuizState?> {
  QuizController(this._repository, this._quizId) : super(null) {
    load();
  }

  final QuizRepository _repository;
  final String _quizId;

  Future<void> load() async {
    final quiz = await _repository.fetchQuiz(_quizId);
    state = QuizState(quiz: quiz);
  }

  void select(String questionId, dynamic answer) {
    final current = state;
    if (current == null || current.result != null) return;
    state = current.copyWith(answers: {...current.answers, questionId: answer});
  }

  Future<void> submit() async {
    final current = state;
    if (current == null) return;
    state = current.copyWith(submitting: true, error: null);
    try {
      final result = await _repository.submit(quizId: _quizId, answers: current.answers);
      state = current.copyWith(result: result, submitting: false, error: null);
    } catch (err) {
      state = current.copyWith(submitting: false, error: err.toString());
    }
  }
}
