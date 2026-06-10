import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> quiz;
  final String moduleId;

  const QuizScreen({super.key, required this.quiz, required this.moduleId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<Map<String, dynamic>> _questions;
  final Map<String, dynamic> _answers = {};
  int _currentQ = 0;
  bool _submitted = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _questions = (widget.quiz['questions'] as List<dynamic>? ?? [])
        .map((q) => Map<String, dynamic>.from(q as Map))
        .toList();
    _questions.sort((a, b) => ((a['order'] as num?) ?? 0).compareTo((b['order'] as num?) ?? 0));
  }

  List<String> _optionsFor(Map<String, dynamic> q) {
    final type = q['type'] as String? ?? 'MCQ';
    if (type == 'TRUE_FALSE') return ['True', 'False'];
    final raw = q['options'];
    if (raw is List) return raw.map((o) => o.toString()).toList();
    return [];
  }

  dynamic _answerValue(String optionText, Map<String, dynamic> q) {
    final type = q['type'] as String? ?? 'MCQ';
    if (type == 'TRUE_FALSE') return optionText == 'True';
    return optionText;
  }

  Future<void> _submit() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Answer all questions first',
              style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
          backgroundColor: SwarajColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final result = await ref.read(apiClientProvider).post(
            '/quiz/submit',
            {'quizId': widget.quiz['id'] as String, 'answers': _answers},
          ) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _result = result;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        setState(() => _submitted = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message,
                style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
            backgroundColor: SwarajColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed',
              style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
          backgroundColor: SwarajColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: SwarajColors.navy),
        ),
        title: Text(
          widget.quiz['titleEn'] as String? ?? 'Quiz',
          style: SwarajTypography.headline(fontSize: 17, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: _submitted ? _buildResultView() : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    if (_questions.isEmpty) {
      return Center(
        child: Text('No questions available', style: SwarajTypography.body()),
      );
    }

    final q = _questions[_currentQ];
    final qId = q['id'] as String? ?? '$_currentQ';
    final prompt = q['promptEn'] as String? ?? '';
    final options = _optionsFor(q);
    final selectedRaw = _answers[qId];
    final selectedDisplay = selectedRaw == null
        ? null
        : (selectedRaw is bool ? (selectedRaw ? 'True' : 'False') : selectedRaw.toString());
    final isLast = _currentQ == _questions.length - 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUESTION ${_currentQ + 1} OF ${_questions.length}',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: SwarajColors.slateLight),
                  ),
                  Text(
                    q['type'] as String? ?? '',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.saffron),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (_currentQ + 1) / _questions.length,
                  minHeight: 4,
                  backgroundColor: SwarajColors.navy.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(SwarajColors.saffron),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prompt,
                    style: SwarajTypography.body(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                ...options.asMap().entries.map((entry) {
                  final optText = entry.value;
                  final isSelected = selectedDisplay == optText;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(
                          () => _answers[qId] = _answerValue(optText, q)),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SwarajColors.navy.withValues(alpha: 0.04)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? SwarajColors.navy
                                : SwarajColors.navy.withValues(alpha: 0.1),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? SwarajColors.navy
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? SwarajColors.navy
                                      : SwarajColors.navy.withValues(alpha: 0.2),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : Text(
                                      String.fromCharCode(65 + entry.key),
                                      style: SwarajTypography.mono(
                                          fontSize: 10,
                                          color: SwarajColors.navy),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(optText,
                                  style: SwarajTypography.body(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_currentQ > 0) ...[
                OutlinedButton(
                  onPressed: () => setState(() => _currentQ--),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    side: BorderSide(
                        color: SwarajColors.navy.withValues(alpha: 0.12)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 16, color: SwarajColors.navy),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedDisplay == null
                      ? null
                      : isLast
                          ? (_isSubmitting ? null : _submit)
                          : () => setState(() => _currentQ++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        SwarajColors.navy.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isLast ? 'SUBMIT' : 'NEXT',
                          style: SwarajTypography.mono(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final correct = (_result?['correct'] as num?)?.toInt();
    final total = (_result?['total'] as num?)?.toInt();
    final score = (_result?['score'] as num?)?.toInt();
    final iqEarned = (_result?['iqEarned'] as num?)?.toInt();
    final attemptsRemaining =
        (_result?['attemptsRemaining'] as num?)?.toInt();
    final results = (_result?['results'] as List<dynamic>?)
            ?.map((r) => Map<String, dynamic>.from(r as Map))
            .toList() ??
        [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SwarajColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: SwarajColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events,
                    size: 36, color: SwarajColors.saffron),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Complete!',
                        style: SwarajTypography.headline(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (correct != null && total != null)
                        Text(
                          '$correct / $total correct · ${score ?? 0}%',
                          style: SwarajTypography.body(
                              fontSize: 14, color: SwarajColors.slate),
                        ),
                      if (iqEarned != null && iqEarned > 0)
                        Text(
                          '+$iqEarned Political IQ',
                          style: SwarajTypography.mono(
                              fontSize: 12,
                              color: SwarajColors.saffron,
                              fontWeight: FontWeight.bold),
                        ),
                      if (attemptsRemaining != null)
                        Text(
                          '$attemptsRemaining attempts remaining',
                          style: SwarajTypography.mono(
                              fontSize: 11, color: SwarajColors.slateLight),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Results',
                style: SwarajTypography.headline(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...results.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isCorrect = r['correct'] as bool? ?? false;
              final explanation = r['explanationEn'] as String? ?? '';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? SwarajColors.success.withValues(alpha: 0.3)
                        : SwarajColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isCorrect
                              ? SwarajColors.success
                              : SwarajColors.error,
                        ),
                        const SizedBox(width: 8),
                        Text('Question ${i + 1}',
                            style: SwarajTypography.mono(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (explanation.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(explanation,
                          style: SwarajTypography.body(
                              fontSize: 13, color: SwarajColors.slate)),
                    ],
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: SwarajColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('DONE',
                  style: SwarajTypography.mono(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
