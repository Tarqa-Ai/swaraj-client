import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';

class LearnScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;
  final ValueChanged<int> onPointsEarned;

  const LearnScreen({
    super.key,
    required this.onTabChange,
    required this.points,
    required this.onPointsEarned,
  });

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  List<Map<String, dynamic>> _modules = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await ref.read(apiClientProvider).get('/modules') as List<dynamic>;
      if (mounted) {
        setState(() {
          _modules = data
              .map((m) => Map<String, dynamic>.from(m as Map))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load curriculum');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _modules;
    final q = _searchQuery.toLowerCase();
    return _modules.where((m) {
      final title = (m['titleEn'] as String? ?? '').toLowerCase();
      final desc = (m['descriptionEn'] as String? ?? '').toLowerCase();
      return title.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
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
            child: Center(child: PointsBadge(points: widget.points)),
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
      body: RefreshIndicator(
        onRefresh: _fetchModules,
        color: SwarajColors.saffron,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACADEMY',
                style: SwarajTypography.mono(
                    fontSize: 11, color: SwarajColors.saffron),
              ),
              const SizedBox(height: 4),
              Text(
                'Curriculum',
                style: SwarajTypography.headline(
                    fontSize: 36, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Master the architecture of democracy through structured, evidence-based modules.',
                style: SwarajTypography.body(),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search topics...',
                  hintStyle:
                      SwarajTypography.body(color: SwarajColors.outline),
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: SwarajColors.slateLight),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: SwarajColors.navy.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: SwarajColors.saffron, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Text(_error!,
                          style: SwarajTypography.body(
                              color: SwarajColors.slate)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchModules,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: SwarajColors.navy,
                            foregroundColor: Colors.white),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (!_isLoading && _filtered.isEmpty && _searchQuery.isNotEmpty)
                Center(
                  child: Text('No modules match "$_searchQuery"',
                      style: SwarajTypography.body(color: SwarajColors.slate)),
                )
              else
                ..._filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final module = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildModuleCard(context, index: index, module: module),
                  );
                }),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: SwarajColors.saffron.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SwarajColors.saffron.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star,
                          size: 28, color: SwarajColors.saffron),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confused by Legalese?',
                            style: SwarajTypography.headline(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ask Swaraj AI to explain any constitutional concept simply.',
                            style: SwarajTypography.body(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => widget.onTabChange(3),
                            icon: const Icon(Icons.psychology, size: 16),
                            label: Text(
                              'EXPLAIN SIMPLY',
                              style: SwarajTypography.mono(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SwarajColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required int index,
    required Map<String, dynamic> module,
  }) {
    final id = module['id'] as String? ?? '';
    final title = module['titleEn'] as String? ?? '';
    final desc = module['descriptionEn'] as String? ?? '';
    final lessonCount = (module['lessonCount'] as num?)?.toInt() ?? 0;
    final completed = module['completed'] as bool? ?? false;
    final lessonProgress = (module['lessons'] as List<dynamic>?)
            ?.where((l) =>
                ((l as Map<String, dynamic>)['progress'] as List<dynamic>?)
                    ?.isNotEmpty ==
                true)
            .length ??
        0;

    final double progress =
        lessonCount > 0 ? lessonProgress / lessonCount : 0.0;
    final bool isCompleted = completed;
    final bool isNotStarted = lessonProgress == 0;

    final Color textColor =
        isCompleted ? SwarajColors.success : SwarajColors.navy;
    final Color progressColor =
        isCompleted ? SwarajColors.success : SwarajColors.saffron;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/module',
        arguments: {'moduleId': id},
      ).then((_) => _fetchModules()),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? SwarajColors.success.withValues(alpha: 0.2)
                : SwarajColors.navy.withValues(alpha: 0.1),
            width: isCompleted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: SwarajTypography.mono(
                    fontSize: 14,
                    color: isCompleted
                        ? SwarajColors.success
                        : SwarajColors.saffron,
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle,
                      size: 18, color: SwarajColors.success),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(desc, style: SwarajTypography.body(fontSize: 14)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: isCompleted ? 1.0 : progress,
                minHeight: 6,
                backgroundColor: SwarajColors.navy.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$lessonProgress / $lessonCount Lessons',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SwarajColors.slate,
                  ),
                ),
                Text(
                  isCompleted
                      ? 'COMPLETE'
                      : isNotStarted
                          ? 'NOT STARTED'
                          : '${(progress * 100).round()}%',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
