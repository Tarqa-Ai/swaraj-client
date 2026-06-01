import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/cache_service.dart';

class CertificateDetailScreen extends ConsumerStatefulWidget {
  const CertificateDetailScreen({super.key});

  @override
  ConsumerState<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState
    extends ConsumerState<CertificateDetailScreen> {
  Map<String, dynamic>? _status;
  Map<String, dynamic>? _cert;
  bool _isLoading = false;
  bool _isDownloading = false;
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
      final status = await ref
          .read(apiClientProvider)
          .get('/certificate/status') as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _status = status);
      final cert = status['certificate'] as Map<String, dynamic>?;
      if (cert != null) {
        setState(() => _cert = cert);
      } else if (status['eligible'] == true) {
        await _downloadCert();
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load certificate');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadCert() async {
    setState(() => _isDownloading = true);
    try {
      final result = await ref
          .read(apiClientProvider)
          .get('/certificate/download') as Map<String, dynamic>;
      if (mounted) setState(() => _cert = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to generate certificate',
              style: SwarajTypography.mono(color: Colors.white, fontSize: 13)),
          backgroundColor: SwarajColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  String get _studentName =>
      SwarajCacheService.getUserProfile()?['name'] as String? ?? '—';

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
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
        title: Text('SWARAJ',
            style: SwarajTypography.headline(
                fontSize: 18, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: (_isLoading || _isDownloading)
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
    if (_isLoading && _status == null) {
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
              onPressed: _fetchStatus,
              style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cert == null) {
      // Not yet eligible — redirect feel
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 56, color: SwarajColors.slateLight),
              const SizedBox(height: 16),
              Text('Certificate Not Yet Earned',
                  style: SwarajTypography.headline(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Complete all modules, one daily challenge, and one debate.',
                textAlign: TextAlign.center,
                style:
                    SwarajTypography.body(fontSize: 14, color: SwarajColors.slate),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text('CONTINUE LEARNING'),
              ),
            ],
          ),
        ),
      );
    }

    final verificationCode = _cert!['verificationCode'] as String? ?? '';
    final issuedAt = _formatDate(_cert!['issuedAt'] as String?);
    final certUrl = _cert!['certificateUrl'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificate card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: SwarajColors.navy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield, size: 40, color: SwarajColors.saffron),
                const SizedBox(height: 16),
                Text(
                  'SWARAJ',
                  style: SwarajTypography.headline(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Certified Young Civic Leader',
                  style: SwarajTypography.mono(
                    fontSize: 14,
                    color: SwarajColors.saffron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                    color: Colors.white24, height: 32, thickness: 0.5),
                Text(
                  'This official document certifies that',
                  style: SwarajTypography.mono(
                      fontSize: 10, color: Colors.white54),
                ),
                const SizedBox(height: 12),
                Text(
                  _studentName,
                  style: SwarajTypography.headline(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'has demonstrated exceptional proficiency in Constitutional Law, Public Policy, and Active Citizenship.',
                  textAlign: TextAlign.center,
                  style: SwarajTypography.body(
                      fontSize: 13, color: Colors.white70),
                ),
                const Divider(
                    color: Colors.white24, height: 32, thickness: 0.5),
                if (issuedAt.isNotEmpty)
                  Text(
                    'Issued: $issuedAt',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: Colors.white54),
                  ),
                if (verificationCode.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Verification: $verificationCode',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: Colors.white38),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (certUrl != null && certUrl.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Opening PDF: $certUrl',
                        style: SwarajTypography.mono(
                            color: Colors.white, fontSize: 13)),
                    backgroundColor: SwarajColors.navy,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: Text('DOWNLOAD PDF',
                    style: SwarajTypography.mono(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back,
                  size: 18, color: SwarajColors.navy),
              label: Text('BACK TO PROFILE',
                  style: SwarajTypography.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SwarajColors.navy)),
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
