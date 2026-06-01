import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/cache_service.dart';
import '../../core/widgets/points_badge.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String moduleId;

  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.moduleId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  Map<String, dynamic>? _lesson;
  bool _isLoading = false;
  bool _isCompleting = false;
  bool _isCompleted = false;
  String? _error;

  int get _points =>
      (SwarajCacheService.getUserProfile()?['points'] as num?)?.toInt() ?? 0;

  @override
  void initState() {
    super.initState();
    _fetchLesson();
  }

  Future<void> _fetchLesson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final module = await ref
          .read(apiClientProvider)
          .get('/modules/${widget.moduleId}') as Map<String, dynamic>;
      final lessons =
          (module['lessons'] as List<dynamic>? ?? [])
              .map((l) => Map<String, dynamic>.from(l as Map))
              .toList();
      final lesson = lessons.firstWhere(
        (l) => l['id'] == widget.lessonId,
        orElse: () => <String, dynamic>{},
      );
      if (!mounted) return;
      if (lesson.isEmpty) {
        setState(() => _error = 'Lesson not found');
      } else {
        final progress = (lesson['progress'] as List<dynamic>?) ?? [];
        setState(() {
          _lesson = lesson;
          _isCompleted = progress.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load lesson');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markComplete() async {
    if (_isCompleting || _isCompleted) return;
    setState(() => _isCompleting = true);
    try {
      await ref
          .read(apiClientProvider)
          .post('/lessons/${widget.lessonId}/complete', {});
      if (!mounted) return;
      setState(() => _isCompleted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lesson complete! Political IQ updated.',
            style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: SwarajColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        setState(() => _isCompleted = true);
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message,
                style:
                    SwarajTypography.mono(color: Colors.white, fontSize: 13)),
            backgroundColor: SwarajColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark complete',
              style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
          backgroundColor: SwarajColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SwarajColors.navy,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shield, size: 14, color: SwarajColors.saffron),
            ),
            const SizedBox(width: 8),
            Text(
              'SWARAJ',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: PointsBadge(points: _points)),
          ),
        ],
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
    if (_isLoading && _lesson == null) {
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
              onPressed: _fetchLesson,
              style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_lesson == null) return const SizedBox.shrink();

    final title = _lesson!['titleEn'] as String? ?? '';
    final body = _lesson!['bodyEn'] as String? ?? '';
    final mediaUrl = _lesson!['mediaUrl'] as String?;
    final paragraphs = body.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SwarajTypography.headline(
                fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mediaUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 24),
          ],
          ...paragraphs.map((para) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(para.trim(), style: SwarajTypography.body()),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isCompleted || _isCompleting ? null : _markComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted
                    ? SwarajColors.success
                    : SwarajColors.navy,
                disabledBackgroundColor: _isCompleted
                    ? SwarajColors.success
                    : SwarajColors.navy.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isCompleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCompleted ? Icons.check_circle : Icons.done,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCompleted ? 'COMPLETED' : 'MARK COMPLETE',
                          style: SwarajTypography.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ai-chat');
              },
              icon: const Icon(Icons.psychology,
                  size: 18, color: SwarajColors.navy),
              label: Text(
                'EXPLAIN SIMPLY (AI)',
                style: SwarajTypography.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SwarajColors.navy,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: SwarajColors.navy.withValues(alpha: 0.15)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
