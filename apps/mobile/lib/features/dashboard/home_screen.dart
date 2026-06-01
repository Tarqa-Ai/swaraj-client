import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/cache_service.dart';
import '../../core/widgets/points_badge.dart';
import 'daily_challenge_screen.dart';
import 'widgets/iq_ring.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;
  final int refreshToken;

  const HomeScreen({
    super.key,
    required this.onTabChange,
    required this.points,
    this.refreshToken = 0,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // User stats
  int _livePoints = 0;
  double _politicalIQ = 0.0;
  int _streak = 0;
  String _name = '';

  // Daily challenge
  Map<String, dynamic>? _challenge;

  // Modules (for Continue Learning)
  List<Map<String, dynamic>> _modules = [];

  // Leaderboard
  List<Map<String, dynamic>> _leaderboardItems = [];
  String? _currentUserId;
  bool _noSchool = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedLocalData();
    _fetchAll();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      _fetchAll();
    }
  }

  void _loadCachedLocalData() {
    final cached = SwarajCacheService.getUserProfile();
    if (cached != null) {
      setState(() {
        _livePoints = (cached['points'] as num?)?.toInt() ?? 0;
        _politicalIQ = (cached['politicalIq'] as num?)?.toDouble() ??
            (cached['politicalIQ'] as num?)?.toDouble() ??
            0.0;
        _streak = (cached['streakCount'] as num?)?.toInt() ??
            (cached['streak'] as num?)?.toInt() ??
            0;
        _name = cached['name'] as String? ?? '';
        _currentUserId = cached['id'] as String?;
      });
    }
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchUserData(),
      _fetchChallenge(),
      _fetchModules(),
      _fetchLeaderboard(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchUserData() async {
    try {
      final data =
          await ref.read(apiClientProvider).get('/me') as Map<String, dynamic>;
      await SwarajCacheService.saveUserProfile(data);
      if (mounted) {
        setState(() {
          _livePoints = (data['points'] as num?)?.toInt() ?? 0;
          _politicalIQ = (data['politicalIq'] as num?)?.toDouble() ?? 0.0;
          _streak = (data['streakCount'] as num?)?.toInt() ?? 0;
          _name = data['name'] as String? ?? '';
          _currentUserId = data['id'] as String?;
        });
      }
    } catch (e) {
      debugPrint('HomeScreen: user fetch failed: $e');
      _loadCachedLocalData();
    }
  }

  Future<void> _fetchChallenge() async {
    try {
      final data = await ref
          .read(apiClientProvider)
          .get('/daily-challenge') as Map<String, dynamic>;
      if (mounted) setState(() => _challenge = data);
    } catch (e) {
      debugPrint('HomeScreen: challenge fetch failed: $e');
    }
  }

  Future<void> _fetchModules() async {
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
      debugPrint('HomeScreen: modules fetch failed: $e');
    }
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final data = await ref
          .read(apiClientProvider)
          .get('/leaderboard') as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((i) => Map<String, dynamic>.from(i as Map))
          .toList();
      if (mounted) {
        setState(() {
          _leaderboardItems = items;
          _noSchool = false;
        });
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404 && mounted) {
        setState(() => _noSchool = true);
      }
    } catch (e) {
      debugPrint('HomeScreen: leaderboard fetch failed: $e');
    }
  }

  List<Map<String, dynamic>> get _inProgressModules {
    return _modules.where((m) {
      final completed = m['completed'] as bool? ?? false;
      if (completed) return false;
      final lessons = (m['lessons'] as List<dynamic>?) ?? [];
      final hasProgress = lessons.any((l) {
        final progress =
            ((l as Map<String, dynamic>)['progress'] as List<dynamic>?) ?? [];
        return progress.isNotEmpty;
      });
      return hasProgress;
    }).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onLongPress: () => Navigator.pushNamed(context, '/admin')
              .then((_) => _fetchAll()),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SwarajColors.navy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.shield,
                    size: 14, color: SwarajColors.saffron),
              ),
              const SizedBox(width: 8),
              Text(
                'SWARAJ',
                style: SwarajTypography.headline(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: PointsBadge(points: _livePoints)),
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
        onRefresh: _fetchAll,
        color: SwarajColors.saffron,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IQ Ring + stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    IQRing(score: _politicalIQ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _streak > 0
                            ? '🔥 $_streak day streak · Keep it up!'
                            : 'Start your civic learning journey today.',
                        textAlign: TextAlign.center,
                        style: SwarajTypography.body(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SwarajColors.saffron.withValues(alpha: 0.08),
                        border: Border.all(
                          color: SwarajColors.saffron.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: '🇮🇳 ',
                              style: TextStyle(fontSize: 14),
                            ),
                            TextSpan(
                              text: 'MY Bharat Initiative: ',
                              style: SwarajTypography.body(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SwarajColors.navy,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "India is mobilising 50 lakh+ young citizens through MY Bharat. You're one of them.",
                              style: SwarajTypography.body(
                                fontSize: 12,
                                color: SwarajColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Daily Challenge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDailyChallengeCard(),
              ),

              // Continue Learning
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Continue Learning',
                      style: SwarajTypography.headline(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => widget.onTabChange(1),
                      child: Text(
                        'View All',
                        style: SwarajTypography.mono(
                            fontSize: 12, color: SwarajColors.saffron),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildContinueLearning(),

              // Leaderboard
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'School Leaderboard',
                  style: SwarajTypography.headline(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLeaderboard(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    if (_challenge == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            'No challenge today — check back tomorrow.',
            style: SwarajTypography.body(
                fontSize: 14, color: SwarajColors.slateLight),
          ),
        ),
      );
    }

    final questions =
        (_challenge!['questions'] as List<dynamic>? ?? [])
            .map((q) => Map<String, dynamic>.from(q as Map))
            .toList();
    final category = _challenge!['category'] as String? ?? 'CHALLENGE';
    final prompt = questions.isNotEmpty
        ? (questions.first['promptEn'] as String? ?? 'Daily Civic Challenge')
        : 'Daily Civic Challenge';
    final completed = _challenge!['completed'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasParliamentAsset())
            Image.asset(
              'assets/parliament.jpg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 8),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.replaceAll('_', ' '),
                      style: SwarajTypography.mono(
                          fontSize: 11, color: SwarajColors.saffron),
                    ),
                    const SizedBox(width: 8),
                    Text('|',
                        style: SwarajTypography.mono(
                            fontSize: 11,
                            color: SwarajColors.outlineVariant)),
                    const SizedBox(width: 8),
                    Text(
                      '${questions.length} QUESTIONS',
                      style: SwarajTypography.mono(
                          fontSize: 11, color: SwarajColors.slate),
                    ),
                    if (completed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: SwarajColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'DONE',
                          style: SwarajTypography.mono(
                              fontSize: 9,
                              color: SwarajColors.success,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prompt,
                  style: SwarajTypography.headline(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: completed
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailyChallengeScreen(
                                    challenge: _challenge!),
                              ),
                            ).then((_) => _fetchAll()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: completed
                          ? SwarajColors.success
                          : SwarajColors.navy,
                      disabledBackgroundColor: SwarajColors.success,
                      disabledForegroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      completed ? 'COMPLETED TODAY' : 'START CHALLENGE',
                      style: SwarajTypography.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasParliamentAsset() {
    // Asset exists in the bundle; show it if available
    return true;
  }

  Widget _buildContinueLearning() {
    final inProgress = _inProgressModules;

    if (_modules.isEmpty) {
      return const SizedBox(height: 8);
    }

    if (inProgress.isEmpty) {
      // Show first 3 modules if no in-progress ones
      final shown = _modules.take(3).toList();
      return SizedBox(
        height: 156,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: shown
              .map((m) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _buildContinueCard(m),
                  ))
              .toList(),
        ),
      );
    }

    return SizedBox(
      height: 156,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: inProgress
            .map((m) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _buildContinueCard(m),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildContinueCard(Map<String, dynamic> module) {
    final id = module['id'] as String? ?? '';
    final title = module['titleEn'] as String? ?? '';
    final lessons = (module['lessons'] as List<dynamic>?) ?? [];
    final lessonCount = (module['lessonCount'] as num?)?.toInt() ??
        lessons.length;
    final lessonProgress = lessons.where((l) {
      final p = ((l as Map<String, dynamic>)['progress'] as List<dynamic>?) ?? [];
      return p.isNotEmpty;
    }).length;
    final progress = lessonCount > 0 ? lessonProgress / lessonCount : 0.0;
    final estimatedMin =
        (module['estimatedMinutes'] as num?)?.toInt() ?? 15;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/module',
          arguments: {'moduleId': id}).then((_) => _fetchModules()),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: SwarajColors.navy.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${estimatedMin}M',
              style: SwarajTypography.mono(
                  fontSize: 10, color: SwarajColors.slateLight),
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SwarajTypography.headline(
                  fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor:
                          SwarajColors.navy.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          SwarajColors.saffron),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progress == 0.0
                      ? 'Not Started'
                      : '${(progress * 100).round()}%',
                  style: SwarajTypography.mono(
                      fontSize: 12, color: SwarajColors.slate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    if (_noSchool) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: SwarajColors.navy.withValues(alpha: 0.08)),
        ),
        child: Text(
          'Complete your profile with a school to see the leaderboard.',
          style:
              SwarajTypography.body(fontSize: 14, color: SwarajColors.slate),
        ),
      );
    }

    if (_leaderboardItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final shown = _leaderboardItems.take(5).toList();
    final userInitials =
        _name.isNotEmpty ? _name[0].toUpperCase() : 'Y';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SwarajColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...shown.map((item) {
            final isMe = item['id'] == _currentUserId;
            final name = item['name'] as String? ?? 'Anonymous';
            final iq = (item['politicalIq'] as num?)?.toInt() ?? 0;
            final rank = (item['rank'] as num?)?.toInt() ?? 0;
            final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
            return _buildLeaderboardItem(
              rank: rank.toString().padLeft(2, '0'),
              avatar: isMe ? userInitials : initials,
              name: isMe ? 'You ($name)' : name,
              subtitle: 'Political IQ: $iq',
              points: _livePoints.toString(),
              isSelf: isMe,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required String rank,
    required String avatar,
    required String name,
    required String subtitle,
    required String points,
    required bool isSelf,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelf
            ? SwarajColors.saffron.withValues(alpha: 0.15)
            : Colors.transparent,
        border: isSelf ? Border.all(color: SwarajColors.saffron) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank,
              style: SwarajTypography.mono(
                fontSize: 14,
                color: isSelf
                    ? SwarajColors.saffron
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: isSelf
                ? SwarajColors.saffron
                : Colors.white.withValues(alpha: 0.1),
            child: Text(
              avatar,
              style: TextStyle(
                color: isSelf
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: SwarajTypography.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SwarajTypography.mono(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          if (isSelf)
            Text(
              points,
              style: SwarajTypography.headline(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SwarajColors.saffron,
              ),
            ),
        ],
      ),
    );
  }
}
