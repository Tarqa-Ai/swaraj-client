import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/points_badge.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  final int points;
  final VoidCallback onResetAllData;

  const ProfileScreen({
    super.key,
    required this.onTabChange,
    required this.points,
    required this.onResetAllData,
  });

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
              child: PointsBadge(points: points),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onResetAllData: onResetAllData,
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
          child: Divider(
              color: SwarajColors.navy.withValues(alpha: 0.06), height: 1),
        ),
      ),
      body: SingleChildScrollView(
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
                      'AK',
                      style: SwarajTypography.headline(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Arjun K. Sharma',
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
                  const SizedBox(height: 4),
                  Text(
                    "St. Xavier's Senior Sec. · Class XII",
                    style: SwarajTypography.body(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MEMBER SINCE',
                        style: SwarajTypography.mono(
                            fontSize: 10, color: SwarajColors.slateLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'August 2023',
                        style: SwarajTypography.mono(
                            fontSize: 12,
                            color: SwarajColors.navy,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('72', 'Political IQ'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('1,452', 'Total Points'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('14', 'Streak Days'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Learning Progress', () => onTabChange(1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SwarajColors.navy.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVERALL COMPLETION',
                    style: SwarajTypography.mono(
                        fontSize: 9, color: SwarajColors.slateLight),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const LinearProgressIndicator(
                            value: 0.55,
                            minHeight: 6,
                            backgroundColor: SwarajColors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                SwarajColors.saffron),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '55%',
                        style: SwarajTypography.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SwarajColors.saffron),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildMiniModuleProgress(
                      number: '01',
                      title: 'Foundations',
                      progressText: '66%',
                      color: SwarajColors.saffron),
                  const SizedBox(height: 12),
                  _buildMiniModuleProgress(
                      number: '02',
                      title: 'Your Rights',
                      progressText: '30%',
                      color: SwarajColors.saffron),
                  const SizedBox(height: 12),
                  _buildMiniModuleProgress(
                      number: '03',
                      title: 'Judiciary',
                      progressText: '100%',
                      color: SwarajColors.success,
                      isComplete: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Achievements',
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementCard(
                    context,
                    label: 'Civic Leader',
                    status: 'Earned',
                    isLocked: false,
                    onTap: () => Navigator.pushNamed(context, '/certificate'),
                  ),
                  const SizedBox(width: 12),
                  _buildAchievementCard(
                    context,
                    label: 'Policy Expert',
                    status: '3/5 Modules',
                    isLocked: true,
                    onTap: () => Navigator.pushNamed(context, '/cert-locked'),
                  ),
                  const SizedBox(width: 12),
                  _buildAchievementCard(
                    context,
                    label: 'Debate Master',
                    status: 'Locked',
                    isLocked: true,
                    onTap: () => _showMockToast(context,
                        'Unlock Debate Master by publishing 5 arguments'),
                  ),
                ],
              ),
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
                    onTap: () => onTabChange(3),
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.card_membership,
                    iconColor: SwarajColors.navy,
                    text: 'View Certificates',
                    onTap: () => Navigator.pushNamed(context, '/certificate'),
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.forum,
                    iconColor: SwarajColors.navy,
                    text: 'Join Debate',
                    onTap: () => onTabChange(2),
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
                            onResetAllData: onResetAllData,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SwarajColors.navy.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COMMUNITY RANK',
                          style: SwarajTypography.mono(
                              fontSize: 9, color: SwarajColors.slateLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Top 15%',
                          style: SwarajTypography.headline(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: SwarajColors.navy),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.trending_up,
                      size: 32, color: SwarajColors.saffron),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
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

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: SwarajTypography.headline(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'View All',
            style: SwarajTypography.mono(
                fontSize: 12, color: SwarajColors.saffron),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniModuleProgress({
    required String number,
    required String title,
    required String progressText,
    required Color color,
    bool isComplete = false,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isComplete
                ? SwarajColors.success
                : SwarajColors.navy.withValues(alpha: 0.04),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isComplete
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text(
                  number,
                  style: SwarajTypography.mono(
                      fontSize: 10, color: SwarajColors.navy),
                ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: SwarajTypography.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SwarajColors.navy),
        ),
        const Spacer(),
        Text(
          progressText,
          style: SwarajTypography.mono(
              fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String label,
    required String status,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLocked
                    ? SwarajColors.navy.withValues(alpha: 0.04)
                    : SwarajColors.saffron.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock_outline : Icons.emoji_events_outlined,
                size: 24,
                color:
                    isLocked ? SwarajColors.slateLight : SwarajColors.saffron,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwarajTypography.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: SwarajColors.navy),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: SwarajTypography.mono(
                fontSize: 9,
                color:
                    isLocked ? SwarajColors.slateLight : SwarajColors.success,
              ),
            ),
          ],
        ),
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
