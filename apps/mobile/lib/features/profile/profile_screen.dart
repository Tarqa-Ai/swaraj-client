import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/services/cache_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  final int points;
  final VoidCallback onResetAllData;

  const ProfileScreen({
    super.key,
    required this.onTabChange,
    required this.points,
    required this.onResetAllData,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final cached = SwarajCacheService.getUserProfile();
    if (cached != null) setState(() => _profile = cached);

    setState(() => _isLoading = true);
    try {
      final data =
          await ref.read(apiClientProvider).get('/me') as Map<String, dynamic>;
      await SwarajCacheService.saveUserProfile(data);
      if (mounted) setState(() => _profile = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _name => _profile?['name'] as String? ?? '';
  String get _avatarInitials {
    final n = _name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return n[0].toUpperCase();
  }

  String get _schoolAndGrade {
    final school = (_profile?['school'] as Map<String, dynamic>?)?['name']
        as String?;
    final grade = _profile?['grade'];
    if (school == null && grade == null) return '';
    if (school != null && grade != null) return '$school · Class $grade';
    return school ?? 'Class $grade';
  }

  String get _memberSince {
    final raw = _profile?['createdAt'] as String?;
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  int get _iq => ((_profile?['politicalIq'] as num?) ?? 0).toInt();
  int get _streak => ((_profile?['streakCount'] as num?) ?? 0).toInt();


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
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: PointsBadge(points: widget.points),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onResetAllData: widget.onResetAllData,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: SwarajColors.navy),
          ),
          const SizedBox(width: 12),
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
        onRefresh: _loadProfile,
        color: SwarajColors.saffron,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: BoxDecoration(
                  color: SwarajColors.navy,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar with saffron ring
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: SwarajColors.saffron, width: 2.5),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: SwarajColors.saffron.withValues(alpha: 0.15),
                        child: Text(
                          _avatarInitials,
                          style: SwarajTypography.headline(
                              fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _name.isEmpty
                        ? Container(
                            width: 140,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            _name,
                            style: SwarajTypography.headline(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      'Citizen of Viksit Bharat @ 2047',
                      style: SwarajTypography.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SwarajColors.saffron,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (_schoolAndGrade.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _schoolAndGrade,
                        style: SwarajTypography.body(
                            fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
                      ),
                    ],
                    if (_memberSince.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'MEMBER SINCE  ',
                              style: SwarajTypography.mono(
                                  fontSize: 9, color: Colors.white.withValues(alpha: 0.45)),
                            ),
                            Text(
                              _memberSince,
                              style: SwarajTypography.mono(
                                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard(_iq.toString(), 'IQ', Icons.psychology_outlined, SwarajColors.saffron)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard(widget.points.toString(), 'Points', Icons.star_outline, SwarajColors.navy)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('$_streak🔥', 'Streak', Icons.local_fire_department_outlined, Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: SwarajTypography.headline(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: SwarajColors.navy.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          _buildActionItem(
                            icon: Icons.psychology,
                            iconColor: SwarajColors.saffron,
                            text: 'Ask Swaraj AI',
                            onTap: () => widget.onTabChange(3),
                          ),
                          const Divider(height: 1),
                          _buildActionItem(
                            icon: Icons.card_membership,
                            iconColor: SwarajColors.navy,
                            text: 'View Certificates',
                            onTap: () =>
                                Navigator.pushNamed(context, '/certificate'),
                          ),
                          const Divider(height: 1),
                          _buildActionItem(
                            icon: Icons.forum,
                            iconColor: SwarajColors.navy,
                            text: 'Join Debate',
                            onTap: () => widget.onTabChange(2),
                          ),
                          const Divider(height: 1),
                          _buildActionItem(
                            icon: Icons.settings,
                            iconColor: SwarajColors.navy,
                            text: 'App Settings',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsScreen(
                                    onResetAllData: widget.onResetAllData,
                                  ),
                                ),
                              );
                            },
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

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: SwarajTypography.headline(
                fontSize: 20, fontWeight: FontWeight.bold, color: SwarajColors.navy),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: SwarajTypography.mono(fontSize: 9, color: SwarajColors.slate),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: SwarajTypography.body(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SwarajColors.navy),
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
