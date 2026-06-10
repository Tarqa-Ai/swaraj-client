import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  Map<String, dynamic>? _module;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchModule();
  }

  Future<void> _fetchModule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(apiClientProvider)
          .get('/modules/${widget.moduleId}') as Map<String, dynamic>;
      if (mounted) setState(() => _module = data);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load module');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          _module?['titleEn'] as String? ?? 'Module',
          style: SwarajTypography.headline(
              fontSize: 17, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading
              ? const LinearProgressIndicator(
                  color: SwarajColors.saffron, minHeight: 2)
              : Divider(
                  color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _module == null) {
      return const Center(
          child: CircularProgressIndicator(color: SwarajColors.saffron));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: SwarajTypography.body()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchModule,
              style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_module == null) return const SizedBox.shrink();

    final title = _module!['titleEn'] as String? ?? '';
    final desc = _module!['descriptionEn'] as String? ?? '';
    final lessons = (_module!['lessons'] as List<dynamic>? ?? [])
        .map((l) => Map<String, dynamic>.from(l as Map))
        .toList();
    final quizzes = (_module!['quizzes'] as List<dynamic>? ?? [])
        .map((q) => Map<String, dynamic>.from(q as Map))
        .toList();
    final moduleCompleted = _module!['completed'] as bool? ?? false;

    return RefreshIndicator(
      onRefresh: _fetchModule,
      color: SwarajColors.saffron,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            title,
            style: SwarajTypography.headline(
                fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(desc, style: SwarajTypography.body(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle,
                  size: 14,
                  color: moduleCompleted
                      ? SwarajColors.success
                      : SwarajColors.slateLight),
              const SizedBox(width: 6),
              Text(
                moduleCompleted
                    ? 'Module Complete'
                    : '${lessons.length} Lessons',
                style: SwarajTypography.mono(
                  fontSize: 11,
                  color: moduleCompleted
                      ? SwarajColors.success
                      : SwarajColors.slateLight,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'LESSONS',
            style: SwarajTypography.mono(
                fontSize: 11, color: SwarajColors.slateLight),
          ),
          const SizedBox(height: 12),
          ...lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final lessonId = lesson['id'] as String? ?? '';
            final lessonTitle =
                lesson['titleEn'] as String? ?? 'Lesson ${index + 1}';
            final progress = (lesson['progress'] as List<dynamic>?) ?? [];
            final isCompleted = progress.isNotEmpty;
            return _buildLessonTile(
              index: index + 1,
              lessonId: lessonId,
              title: lessonTitle,
              isCompleted: isCompleted,
            );
          }),
          if (quizzes.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              'QUIZZES',
              style: SwarajTypography.mono(
                  fontSize: 11, color: SwarajColors.slateLight),
            ),
            const SizedBox(height: 12),
            ...quizzes.map((quiz) {
              final quizTitle = quiz['titleEn'] as String? ?? 'Quiz';
              final questionCount =
                  (quiz['questions'] as List<dynamic>?)?.length ?? 0;
              return _buildQuizTile(quiz: quiz, title: quizTitle, questionCount: questionCount);
            }),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuizTile({
    required Map<String, dynamic> quiz,
    required String title,
    required int questionCount,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/quiz',
        arguments: {'quiz': quiz, 'moduleId': widget.moduleId},
      ).then((_) => _fetchModule()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: SwarajColors.saffron.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: SwarajColors.saffron.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.quiz, size: 16, color: SwarajColors.saffron),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SwarajTypography.body(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SwarajColors.navy,
                    ),
                  ),
                  Text(
                    '$questionCount question${questionCount == 1 ? '' : 's'}',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: SwarajColors.slateLight),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: SwarajColors.slateLight),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTile({
    required int index,
    required String lessonId,
    required String title,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/lesson',
        arguments: {'lessonId': lessonId, 'moduleId': widget.moduleId},
      ).then((_) => _fetchModule()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? SwarajColors.success.withValues(alpha: 0.3)
                : SwarajColors.navy.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? SwarajColors.success.withValues(alpha: 0.1)
                    : SwarajColors.navy.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(Icons.check,
                      size: 16, color: SwarajColors.success)
                  : Text(
                      '$index',
                      style: SwarajTypography.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: SwarajColors.navy),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: SwarajTypography.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SwarajColors.navy,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: SwarajColors.slateLight),
          ],
        ),
      ),
    );
  }
}
