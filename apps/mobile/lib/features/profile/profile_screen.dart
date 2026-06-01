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

  void _showToast(BuildContext context, String message) {
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: SwarajColors.navy,
                      child: Text(
                        _avatarInitials,
                        style: SwarajTypography.headline(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _name.isEmpty
                        ? Container(
                            width: 140,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            _name,
                            style: SwarajTypography.headline(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(height: 2),
                    Text(
                      'Citizen of Viksit Bharat @ 2047',
                      style: SwarajTypography.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: SwarajColors.saffron,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (_schoolAndGrade.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _schoolAndGrade,
                        style: SwarajTypography.body(fontSize: 14),
                      ),
                    ],
                    if (_memberSince.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'MEMBER SINCE',
                            style: SwarajTypography.mono(
                                fontSize: 10,
                                color: SwarajColors.slateLight),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _memberSince,
                            style: SwarajTypography.mono(
                                fontSize: 12,
                                color: SwarajColors.navy,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(_iq.toString(), 'Political IQ'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(widget.points.toString(), 'Total Points'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(_streak.toString(), 'Streak Days'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: SwarajTypography.headline(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style:
                SwarajTypography.mono(fontSize: 9, color: SwarajColors.slate),
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
