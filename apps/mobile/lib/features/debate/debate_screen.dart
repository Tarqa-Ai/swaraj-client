import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';

class DebateScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;

  const DebateScreen({
    super.key,
    required this.onTabChange,
    required this.points,
  });

  @override
  ConsumerState<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends ConsumerState<DebateScreen> {
  Map<String, dynamic>? _debate;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _selectedSide;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDebate();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _fetchDebate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).get('/debate/current')
          as Map<String, dynamic>;
      if (mounted) setState(() => _debate = data);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.statusCode == 404 ? null : e.message;
          if (e.statusCode == 404) _debate = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load debate');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitResponse() async {
    final side = _selectedSide;
    final reflection = _reflectionController.text.trim();
    if (side == null) {
      _showToast('Please pick a side first');
      return;
    }
    if (reflection.length < 30) {
      _showToast('Reflection must be at least 30 characters');
      return;
    }
    if (_debate == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(apiClientProvider).post('/debate/respond', {
        'debateId': _debate!['id'] as String,
        'side': side,
        'reflection': reflection,
      });
      if (!mounted) return;
      setState(() {
        _debate = Map<String, dynamic>.from(_debate!)..['responded'] = true;
      });
      _showToast('Your reflection has been published!');
    } on ApiException catch (e) {
      if (!mounted) return;
      _showToast(e.message);
    } catch (_) {
      if (!mounted) return;
      _showToast('Submission failed. Try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              child: const Icon(
                Icons.shield,
                size: 14,
                color: SwarajColors.saffron,
              ),
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
            child: Center(
              child: PointsBadge(points: widget.points),
            ),
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
        onRefresh: _fetchDebate,
        color: SwarajColors.saffron,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _debate == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator(color: SwarajColors.saffron),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: SwarajColors.slateLight),
              const SizedBox(height: 16),
              Text(_error!,
                  style: SwarajTypography.body(color: SwarajColors.slate)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDebate,
                style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_debate == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              const Icon(Icons.forum_outlined,
                  size: 56, color: SwarajColors.slateLight),
              const SizedBox(height: 16),
              Text('No Active Debate',
                  style: SwarajTypography.headline(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Check back soon — a new motion is coming.',
                textAlign: TextAlign.center,
                style: SwarajTypography.body(color: SwarajColors.slate),
              ),
            ],
          ),
        ),
      );
    }

    final responded = _debate!['responded'] as bool? ?? false;
    final topicEn = _debate!['topicEn'] as String? ?? '';
    final forSummary = _debate!['forSummaryEn'] as String? ?? '';
    final againstSummary = _debate!['againstSummaryEn'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FEATURED MOTION',
          style: SwarajTypography.mono(
              fontSize: 11, color: SwarajColors.saffron),
        ),
        const SizedBox(height: 12),
        Text(
          topicEn,
          style: SwarajTypography.headline(
              fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // For / Against summary cards
        _buildSideCard(
          title: 'FOR',
          content: forSummary,
          color: SwarajColors.success,
        ),
        const SizedBox(height: 12),
        _buildSideCard(
          title: 'AGAINST',
          content: againstSummary,
          color: SwarajColors.error,
        ),
        const Divider(height: 40),

        if (responded)
          _buildRespondedState()
        else
          _buildResponseForm(),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSideCard({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              title,
              style: SwarajTypography.mono(
                  fontSize: 10, color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(content, style: SwarajTypography.body(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRespondedState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwarajColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwarajColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: SwarajColors.success, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You've Participated",
                  style: SwarajTypography.headline(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your reflection is recorded. Political IQ updated.',
                  style: SwarajTypography.body(
                      fontSize: 13, color: SwarajColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stand',
          style: SwarajTypography.headline(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSideButton(
                label: 'FOR',
                color: SwarajColors.success,
                selected: _selectedSide == 'FOR',
                onTap: () => setState(() => _selectedSide = 'FOR'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSideButton(
                label: 'AGAINST',
                color: SwarajColors.error,
                selected: _selectedSide == 'AGAINST',
                onTap: () => setState(() => _selectedSide = 'AGAINST'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Your Reflection',
          style: SwarajTypography.headline(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Min 30 characters. Make a reasoned civic argument.',
          style: SwarajTypography.body(
              fontSize: 12, color: SwarajColors.slateLight),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _reflectionController,
                maxLines: 5,
                maxLength: 800,
                style:
                    SwarajTypography.body(fontSize: 14, color: SwarajColors.navy),
                decoration: InputDecoration(
                  hintText:
                      'Consider the constitutional implications and civic duties...',
                  hintStyle: SwarajTypography.body(
                      fontSize: 14, color: SwarajColors.outline),
                  border: InputBorder.none,
                  counterStyle: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => widget.onTabChange(3),
                    icon: const Icon(Icons.psychology,
                        size: 18, color: SwarajColors.saffron),
                    tooltip: 'Ask AI for help',
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitResponse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'PUBLISH',
                            style: SwarajTypography.mono(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : SwarajColors.navy.withValues(alpha: 0.1),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected)
              Icon(Icons.check_circle, size: 16, color: color),
            if (selected) const SizedBox(width: 6),
            Text(
              label,
              style: SwarajTypography.mono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? color : SwarajColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
