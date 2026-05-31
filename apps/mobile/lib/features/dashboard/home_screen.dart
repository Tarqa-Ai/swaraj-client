import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/config.dart';
import '../../core/services/cache_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';
import 'widgets/iq_ring.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;

  const HomeScreen({
    super.key,
    required this.onTabChange,
    required this.points,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _livePoints = 1452;
  double _politicalIQ = 72.0;
  int _streak = 14;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedLocalData();
    _fetchLiveUserData();
  }

  void _loadCachedLocalData() {
    final cached = SwarajCacheService.getUserProfile();
    if (cached != null) {
      setState(() {
        _livePoints = cached['points'] ?? 1452;
        _politicalIQ = (cached['politicalIQ'] as num?)?.toDouble() ?? 72.0;
        _streak = cached['streak'] ?? 14;
      });
    }
  }

  Future<void> _fetchLiveUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('${SwarajConfig.apiBaseUrl}/users/9876543210'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await SwarajCacheService.saveUserProfile(data);
        if (mounted) {
          setState(() {
            _livePoints = data['points'] ?? 1452;
            _politicalIQ = (data['politicalIQ'] as num?)?.toDouble() ?? 72.0;
            _streak = data['streak'] ?? 14;
          });
        }
      }
    } catch (e) {
      debugPrint(
          'Failed to sync live user data inside HomeScreen: $e. Using local disk cache.');
      _loadCachedLocalData();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMockToast(BuildContext context, String message) {
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onLongPress: () {
            Navigator.pushNamed(context, '/admin')
                .then((_) => _fetchLiveUserData());
          },
          child: Row(
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
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: PointsBadge(points: _livePoints),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: _isLoading
              ? const LinearProgressIndicator(
                  color: SwarajColors.saffron, minHeight: 1)
              : Divider(
                  color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveUserData,
        color: SwarajColors.saffron,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    IQRing(score: _politicalIQ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "You're in the top 15% of citizens this month. Keep up the enlightened streak!",
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: SwarajColors.navy.withValues(alpha: 0.1)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/parliament.jpg',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'DAILY CHALLENGE',
                                  style: SwarajTypography.mono(
                                      fontSize: 11,
                                      color: SwarajColors.saffron),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '|',
                                  style: SwarajTypography.mono(
                                      fontSize: 11,
                                      color: SwarajColors.outlineVariant),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '5 MINS',
                                  style: SwarajTypography.mono(
                                      fontSize: 11, color: SwarajColors.slate),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'The Limits of Freedom of Speech',
                              style: SwarajTypography.headline(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Explore the nuances of Article 19(1)(a) and the 'reasonable restrictions' that balance individual liberty with national security.",
                              style: SwarajTypography.body(fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/lesson');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SwarajColors.navy,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'START CHALLENGE',
                                  style: SwarajTypography.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                '"The Election Commission\'s SVEEP mission: building a participative democracy. Swaraj brings it to your screen."',
                                textAlign: TextAlign.center,
                                style: SwarajTypography.mono(
                                  fontSize: 9,
                                  color: SwarajColors.slateLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              SizedBox(
                height: 156,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildContinueCard(
                      context,
                      category: 'CONSTITUTION',
                      time: '12M',
                      title: 'The Preamble: We, the People',
                      progress: 0.45,
                    ),
                    const SizedBox(width: 14),
                    _buildContinueCard(
                      context,
                      category: 'CIVICS',
                      time: '18M',
                      title: 'Separation of Powers',
                      progress: 0.15,
                    ),
                    const SizedBox(width: 14),
                    _buildContinueCard(
                      context,
                      category: 'ELECTIONS',
                      time: '10M',
                      title: 'The Election Commission',
                      progress: 0.0,
                    ),
                  ],
                ),
              ),
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
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SwarajColors.navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildLeaderboardItem(
                        rank: '01',
                        avatar: 'AS',
                        name: 'Aditya Singh',
                        subtitle: "St. Xavier's Senior Sec.",
                        points: '2,840',
                        isSelf: false,
                      ),
                      _buildLeaderboardItem(
                        rank: '14',
                        avatar: 'D',
                        name: 'You (Deepak)',
                        subtitle: '🔥 $_streak day streak',
                        points: _livePoints.toString(),
                        isSelf: true,
                      ),
                      _buildLeaderboardItem(
                        rank: '15',
                        avatar: 'SR',
                        name: 'Sneha Reddy',
                        subtitle: "St. Xavier's Senior Sec.",
                        points: '1,410',
                        isSelf: false,
                      ),
                      const Divider(color: Colors.white10),
                      TextButton(
                        onPressed: () => _showMockToast(
                            context, 'Full leaderboard coming soon'),
                        child: Text(
                          'SEE FULL LEADERBOARD',
                          style: SwarajTypography.mono(
                              fontSize: 11, color: SwarajColors.saffron),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueCard(
    BuildContext context, {
    required String category,
    required String time,
    required String title,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/lesson'),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  category,
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
                const SizedBox(width: 8),
                Text(
                  '|',
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.outlineVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.slateLight),
                ),
              ],
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
                color:
                    isSelf ? Colors.white : Colors.white.withValues(alpha: 0.4),
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
          const SizedBox(width: 8),
          Text(
            points,
            style: SwarajTypography.headline(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelf
                  ? SwarajColors.saffron
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
