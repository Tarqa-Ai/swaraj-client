import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class CertLockedScreen extends ConsumerStatefulWidget {
  const CertLockedScreen({super.key});

  @override
  ConsumerState<CertLockedScreen> createState() => _CertLockedScreenState();
}

class _CertLockedScreenState extends ConsumerState<CertLockedScreen> {
  Map<String, dynamic>? _status;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ref
          .read(apiClientProvider)
          .get('/certificate/status') as Map<String, dynamic>;
      if (mounted) {
        setState(() => _status = data);
        final eligible = data['eligible'] as bool? ?? false;
        if (eligible) {
          Navigator.pushReplacementNamed(context, '/certificate');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load certificate status');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = (_status?['completedModules'] as num?)?.toInt() ?? 0;
    final total = (_status?['totalModules'] as num?)?.toInt() ?? 0;
    final progress = total > 0 ? completed / total : 0.0;
    final challenges = (_status?['challenges'] as num?)?.toInt() ?? 0;
    final debates = (_status?['debates'] as num?)?.toInt() ?? 0;

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
          'SWARAJ',
          style: SwarajTypography.headline(
              fontSize: 18, fontWeight: FontWeight.w800),
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
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: SwarajTypography.body()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchStatus,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: SwarajColors.navy,
                        foregroundColor: Colors.white),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACHIEVEMENT MERIT',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: SwarajColors.saffron),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Civic Excellence',
                    style: SwarajTypography.headline(
                        fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: SwarajColors.navy.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SwarajColors.saffron.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock,
                              size: 32, color: SwarajColors.saffron),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Requirement Pending',
                          style: SwarajTypography.headline(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete all modules, at least one daily challenge, and one debate to unlock your certificate.',
                          textAlign: TextAlign.center,
                          style: SwarajTypography.body(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        _buildRequirementRow(
                          label: 'Modules Completed',
                          value: '$completed / $total',
                          done: total > 0 && completed >= total,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: SwarajColors.surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                SwarajColors.saffron),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRequirementRow(
                          label: 'Daily Challenges',
                          value: challenges > 0 ? 'Done' : 'Pending',
                          done: challenges > 0,
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow(
                          label: 'Debate Participation',
                          value: debates > 0 ? 'Done' : 'Pending',
                          done: debates > 0,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SwarajColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text(
                              'CONTINUE LEARNING',
                              style: SwarajTypography.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRequirementRow({
    required String label,
    required String value,
    required bool done,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: SwarajTypography.mono(
                fontSize: 12, color: SwarajColors.slate)),
        Row(
          children: [
            if (done)
              const Icon(Icons.check_circle,
                  size: 14, color: SwarajColors.success),
            const SizedBox(width: 4),
            Text(
              value,
              style: SwarajTypography.mono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: done ? SwarajColors.success : SwarajColors.navy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
