import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';

class DebateScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;

  const DebateScreen({
    super.key,
    required this.onTabChange,
    required this.points,
  });

  @override
  State<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  bool _hasVoted = false;
  double _favorPct = 42.0;
  double _againstPct = 58.0;

  final TextEditingController _argumentController = TextEditingController();
  String _activeTab = 'All';

  @override
  void dispose() {
    _argumentController.dispose();
    super.dispose();
  }

  void _castVote() {
    if (_hasVoted) return;
    setState(() {
      _hasVoted = true;
      _favorPct = 43.0;
      _againstPct = 57.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your vote has been recorded!',
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _publishArgument() {
    final text = _argumentController.text.trim();
    if (text.isEmpty) return;
    _argumentController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Argument published!',
          style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: SwarajColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
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
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FEATURED MOTION',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.saffron),
                ),
                const SizedBox(width: 8),
                Text(
                  '|',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.outlineVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  'WEEK 42',
                  style: SwarajTypography.mono(
                      fontSize: 11, color: SwarajColors.slateLight),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '🗳️ "25 January — National Voters\' Day. Pledge to vote."',
              style: SwarajTypography.mono(
                fontSize: 10,
                color: SwarajColors.saffron,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              'Should voting be mandatory in India?',
              style: SwarajTypography.headline(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'In Favor (${_favorPct.round()}%)',
                  style: SwarajTypography.mono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SwarajColors.saffron,
                  ),
                ),
                Text(
                  'Against (${_againstPct.round()}%)',
                  style: SwarajTypography.mono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SwarajColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: SwarajColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth * (_favorPct / 100.0),
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: SwarajColors.saffron,
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(100)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '1,248 students have cast their vote. Participation strengthens democracy.',
              style: SwarajTypography.body(fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _hasVoted ? null : _castVote,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasVoted ? SwarajColors.success : SwarajColors.navy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: SwarajColors.success,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _hasVoted ? 'VOTED' : 'VOTE NOW',
                  style: SwarajTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Divider(height: 48),
            Text(
              'Your Reflection',
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '"Echoing the Viksit Bharat Young Leaders Dialogue — your voice, on the national stage."',
              style: SwarajTypography.body(
                fontSize: 12,
                color: SwarajColors.slateLight,
              ).copyWith(fontStyle: FontStyle.italic),
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
                  Text(
                    'CONSTRUCT YOUR ARGUMENT',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.slateLight),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _argumentController,
                    maxLines: 4,
                    style: SwarajTypography.body(
                        fontSize: 14, color: SwarajColors.navy),
                    decoration: InputDecoration(
                      hintText:
                          'Consider the constitutional implications, civic duties, and logistical challenges...',
                      hintStyle: SwarajTypography.body(
                          fontSize: 14, color: SwarajColors.outline),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.link,
                                size: 18, color: SwarajColors.slateLight),
                            tooltip: 'Add Source',
                          ),
                          IconButton(
                            onPressed: () => widget.onTabChange(3),
                            icon: const Icon(Icons.psychology,
                                size: 18, color: SwarajColors.saffron),
                            tooltip: 'AI Assist',
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _publishArgument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SwarajColors.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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
            const Divider(height: 48),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Public Pulse', 'All', 'Your School', 'Followed']
                    .map((tab) {
                  final bool isActive = _activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _activeTab = tab;
                          });
                        }
                      },
                      labelStyle: SwarajTypography.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : SwarajColors.navy,
                      ),
                      selectedColor: SwarajColors.navy,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: isActive
                              ? SwarajColors.navy
                              : SwarajColors.navy.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildCommentCard(
                  author: '@AryanK_24',
                  school: 'KV No. 1, Delhi',
                  text:
                      'Mandatory voting could ensure that the government truly represents the will of the majority. However, we must first address the accessibility of polling stations for rural citizens.',
                  likes: 24,
                ),
                _buildCommentCard(
                  author: 'DPS Mathura',
                  school: 'School Profile',
                  text:
                      'Rights and duties are two sides of the same coin. If we enjoy the rights of a democracy, it is our duty to participate in its preservation. Mandatory voting is just a nudge toward civic maturity.',
                  likes: 112,
                  isFeatured: true,
                ),
                _buildCommentCard(
                  author: '@Meera_99',
                  school: 'Modern School',
                  text:
                      'Doesn\'t forcing someone to vote violate their right to remain neutral? Silence is also a form of speech in a democratic setup.',
                  likes: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Loading more perspectives...',
                        style: SwarajTypography.mono(
                            color: Colors.white, fontSize: 13),
                      ),
                      backgroundColor: SwarajColors.navy,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'LOAD MORE PERSPECTIVES',
                  style: SwarajTypography.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SwarajColors.navy),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard({
    required String author,
    required String school,
    required String text,
    required int likes,
    bool isFeatured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFeatured
              ? SwarajColors.saffron.withValues(alpha: 0.3)
              : SwarajColors.navy.withValues(alpha: 0.08),
          width: isFeatured ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isFeatured) ...[
                const Icon(Icons.star, size: 14, color: SwarajColors.saffron),
                const SizedBox(width: 6),
              ],
              Text(
                author,
                style: SwarajTypography.mono(
                    fontSize: 11, color: SwarajColors.navy),
              ),
              const Spacer(),
              Text(
                school,
                style: SwarajTypography.mono(
                    fontSize: 10, color: SwarajColors.slateLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style:
                SwarajTypography.body(fontSize: 14, color: SwarajColors.slate),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined,
                        size: 14, color: SwarajColors.slateLight),
                    const SizedBox(width: 6),
                    Text(
                      '$likes',
                      style: SwarajTypography.mono(
                          fontSize: 12, color: SwarajColors.slateLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.reply,
                        size: 14, color: SwarajColors.slateLight),
                    const SizedBox(width: 6),
                    Text(
                      'Reply',
                      style: SwarajTypography.mono(
                          fontSize: 12, color: SwarajColors.slateLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
