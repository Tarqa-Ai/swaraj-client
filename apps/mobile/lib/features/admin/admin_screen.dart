import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

// Web Client ID from Google Console — must match GOOGLE_CLIENT_ID in backend .env
const _googleWebClientId =
    '213528243845-kmg8av6caecqlbngmr0gpn2o25aq8rd3.apps.googleusercontent.com';

class AdminScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const AdminScreen({super.key, required this.onDataChanged});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _baseUrl = SwarajConfig.apiBaseUrl;

  // Admin JWT — obtained via /auth/admin/login
  String? _adminToken;

  List<dynamic> _students = [];
  List<dynamic> _modules = [];
  List<dynamic> _debates = [];

  int _totalUsers = 0;
  int _activeUsers = 0;
  double _avgIQ = 0.0;
  int _totalModules = 0;

  bool _isLoading = false;

  // Debate Form Controller
  final _debateTopicController = TextEditingController();

  final List<String> _systemLogs = [
    "[SYSTEM] Swaraj Admin Panel v2.0",
    "[OK] Connected to backend: ${SwarajConfig.apiBaseUrl}",
    "[NOTICE] Admin JWT required — use login to authenticate",
  ];

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_adminToken != null) 'Authorization': 'Bearer $_adminToken',
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchDataForActiveTab();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loginWithGoogle());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debateTopicController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    setState(() {
      final timeStr = TimeOfDay.now().format(context);
      _systemLogs.add("[$timeStr] $msg");
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: SwarajTypography.mono(color: Colors.white, fontSize: 12)),
        backgroundColor: SwarajColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(serverClientId: _googleWebClientId);
      final account = await googleSignIn.signIn();
      if (account == null) {
        _addLog("[NOTICE] Google Sign-In cancelled");
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        _addLog("[ERROR] No ID token received from Google");
        _showToast('Google Sign-In failed — no ID token');
        return;
      }
      _addLog("[AUTH] Google token received, verifying with backend...");
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/admin/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        setState(() => _adminToken = body['accessToken'] as String?);
        _addLog("[AUTH] Admin authenticated via Google");
        _fetchDashboardMetrics();
      } else {
        _addLog("[ERROR] Auth failed: ${res.statusCode} ${res.body}");
        _showToast('Access denied — only the designated admin account is allowed');
      }
    } catch (e) {
      _addLog("[ERROR] Google Sign-In error: $e");
      _showToast('Sign-In error: $e');
    }
  }

  Future<void> _fetchDashboardMetrics() async {
    if (_adminToken == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/analytics'),
        headers: _authHeaders,
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          _totalUsers = (data['totalUsers'] as num?)?.toInt() ?? 0;
          _activeUsers = (data['activeUsers'] as num?)?.toInt() ?? 0;
          _avgIQ = (data['avgPoliticalIq'] as num?)?.toDouble() ?? 0.0;
          _totalModules = (data['totalModules'] as num?)?.toInt() ?? 0;
        });
        _addLog("[LOAD] Analytics loaded");
      }
    } catch (e) {
      _addLog("[ERROR] Analytics fetch failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDataForActiveTab() async {
    final index = _tabController.index;
    if (index == 0) _fetchDashboardMetrics();
    if (index == 1) _fetchStudents();
    if (index == 2) _fetchModules();
    if (index == 3) _fetchDebates();
  }

  Future<void> _fetchStudents() async {
    if (_adminToken == null) return;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/students?limit=50'),
        headers: _authHeaders,
      );
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        setState(() => _students = (body['data'] as List<dynamic>?) ?? []);
        _addLog("[LOAD] Loaded ${_students.length} students");
      }
    } catch (e) {
      _addLog("[ERROR] Students fetch failed: $e");
    }
  }

  Future<void> _fetchModules() async {
    if (_adminToken == null) return;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/modules'),
        headers: _authHeaders,
      );
      if (res.statusCode == 200) {
        setState(() => _modules = json.decode(res.body) as List<dynamic>);
        _addLog("[LOAD] Loaded ${_modules.length} modules");
      }
    } catch (e) {
      _addLog("[ERROR] Modules fetch failed: $e");
    }
  }

  Future<void> _fetchDebates() async {
    if (_adminToken == null) return;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/debates'),
        headers: _authHeaders,
      );
      if (res.statusCode == 200) {
        setState(() => _debates = json.decode(res.body) as List<dynamic>);
        _addLog("[LOAD] Loaded ${_debates.length} debates");
      }
    } catch (e) {
      _addLog("[ERROR] Debates fetch failed: $e");
    }
  }

  Future<void> _suspendStudent(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Suspension'),
        content: Text('Suspend $name? Their account will be disabled.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: SwarajColors.error),
            child: const Text('SUSPEND'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/admin/students/$id'),
        headers: _authHeaders,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showToast('Student suspended');
        _addLog("[SUSPEND] Suspended student $name ($id)");
        _fetchStudents();
      } else {
        _showToast('Failed: ${res.statusCode}');
      }
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> _launchDebate() async {
    final topic = _debateTopicController.text.trim();
    if (topic.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/admin/debates'),
        headers: _authHeaders,
        body: json.encode({
          'topicEn': topic,
          'topicHi': topic,
          'forSummaryEn': 'Arguments in favour of the motion.',
          'forSummaryHi': 'प्रस्ताव के पक्ष में तर्क।',
          'againstSummaryEn': 'Arguments against the motion.',
          'againstSummaryHi': 'प्रस्ताव के विरुद्ध तर्क।',
          'isActive': true,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showToast('Debate launched!');
        _addLog("[DEBATE] Launched: \"$topic\"");
        _debateTopicController.clear();
        _fetchDebates();
        widget.onDataChanged();
      } else {
        _showToast('Failed: ${res.statusCode}');
      }
    } catch (e) {
      _showToast('Error: $e');
    }
  }

  Future<void> _toggleDebateActive(String id, bool currentlyActive) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/admin/debates/$id'),
        headers: _authHeaders,
        body: json.encode({'isActive': !currentlyActive}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showToast(currentlyActive ? 'Debate deactivated' : 'Debate activated');
        _fetchDebates();
      }
    } catch (e) {
      _showToast('Error: $e');
    }
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
              child: const Icon(Icons.shield, size: 14, color: SwarajColors.saffron),
            ),
            const SizedBox(width: 8),
            Text('SWARAJ ADMIN',
                style: SwarajTypography.headline(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          if (_adminToken != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: SwarajColors.saffron),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('PRIVILEGED',
                  style: SwarajTypography.mono(
                      fontSize: 8, color: SwarajColors.saffron, fontWeight: FontWeight.bold)),
            )
          else
            TextButton(
              onPressed: _loginWithGoogle,
              child: Text('LOGIN', style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.saffron)),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: SwarajColors.saffron,
          unselectedLabelColor: SwarajColors.slate,
          indicatorColor: SwarajColors.saffron,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Students'),
            Tab(text: 'Modules'),
            Tab(text: 'Debates'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: SwarajColors.saffron))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildStudentsTab(),
                _buildModulesTab(),
                _buildDebatesTab(),
                _buildLogsTab(),
              ],
            ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Statistics',
              style: SwarajTypography.headline(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard(_totalUsers.toString(), 'TOTAL USERS')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(_activeUsers.toString(), 'ACTIVE (30D)')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(_avgIQ.toStringAsFixed(1), 'AVG IQ')),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(_totalModules.toString(), 'MODULES')),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _fetchDashboardMetrics,
              style: ElevatedButton.styleFrom(
                  backgroundColor: SwarajColors.navy, foregroundColor: Colors.white),
              child: Text('REFRESH ANALYTICS',
                  style: SwarajTypography.mono(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(val,
              style: SwarajTypography.headline(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: SwarajTypography.mono(
                  fontSize: 7, color: SwarajColors.slateLight, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: _fetchStudents,
              child: Text('LOAD / REFRESH STUDENTS',
                  style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.navy)),
            ),
          ),
        ),
        Expanded(
          child: _students.isEmpty
              ? const Center(child: Text('No students loaded. Tap refresh.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _students.length,
                  itemBuilder: (context, idx) {
                    final u = _students[idx];
                    final school = u['school'] as Map<String, dynamic>?;
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: SwarajColors.navy.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(u['name'] as String? ?? '(no name)',
                                      style: SwarajTypography.headline(
                                          fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                                Text('IQ: ${u['politicalIq'] ?? 0}',
                                    style: SwarajTypography.mono(
                                        fontSize: 11,
                                        color: SwarajColors.saffron,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(u['email'] as String? ?? '',
                                style: SwarajTypography.body(fontSize: 12, color: SwarajColors.slate)),
                            if (u['phone'] != null)
                              Text(u['phone'] as String,
                                  style: SwarajTypography.mono(fontSize: 10, color: SwarajColors.slate)),
                            if (school != null)
                              Text(school['name'] as String? ?? '',
                                  style: SwarajTypography.body(fontSize: 11, color: SwarajColors.slate)),
                            const SizedBox(height: 8),
                            Text('Streak: ${u['streakCount'] ?? 0} days',
                                style: SwarajTypography.mono(fontSize: 11)),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _suspendStudent(u['id'] as String, u['name'] as String? ?? ''),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: SwarajColors.error.withValues(alpha: 0.1),
                                    elevation: 0),
                                child: Text('SUSPEND',
                                    style: SwarajTypography.mono(fontSize: 10, color: SwarajColors.error)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModulesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: _fetchModules,
              child: Text('LOAD / REFRESH MODULES',
                  style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.navy)),
            ),
          ),
        ),
        Expanded(
          child: _modules.isEmpty
              ? const Center(child: Text('No modules loaded. Tap refresh.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _modules.length,
                  itemBuilder: (ctx, idx) {
                    final m = _modules[idx];
                    final lessons = (m['lessons'] as List<dynamic>?)?.length ?? 0;
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: SwarajColors.navy.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SwarajColors.navy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${m['order'] ?? idx + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(m['titleEn'] as String? ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['descriptionEn'] as String? ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text('$lessons lessons',
                            style: SwarajTypography.mono(
                                fontSize: 10, color: SwarajColors.saffron)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDebatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Launch New Debate',
              style: SwarajTypography.headline(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _debateTopicController,
                  decoration: const InputDecoration(
                    hintText: 'Enter debate topic in English...',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _launchDebate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.navy, foregroundColor: Colors.white),
                  child: Text('LAUNCH',
                      style: SwarajTypography.mono(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Debates',
                  style: SwarajTypography.headline(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _fetchDebates,
                child: Text('REFRESH',
                    style: SwarajTypography.mono(fontSize: 11, color: SwarajColors.saffron)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_debates.isEmpty)
            const Center(child: Text('No debates loaded.'))
          else
            ..._debates.map((d) {
              final isActive = d['isActive'] as bool? ?? false;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: isActive
                          ? SwarajColors.saffron
                          : SwarajColors.navy.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: SwarajColors.saffron,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('ACTIVE',
                                    style: SwarajTypography.mono(
                                        fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            Text(d['topicEn'] as String? ?? '',
                                style: SwarajTypography.body(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _toggleDebateActive(d['id'] as String, isActive),
                        child: Text(isActive ? 'DEACTIVATE' : 'ACTIVATE',
                            style: SwarajTypography.mono(
                                fontSize: 10,
                                color: isActive ? SwarajColors.error : SwarajColors.navy)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _systemLogs.length,
        itemBuilder: (context, idx) {
          final log = _systemLogs[idx];
          Color col = Colors.green;
          if (log.contains("NOTICE")) col = SwarajColors.saffron;
          if (log.contains("ERROR")) col = Colors.red;
          if (log.contains("SYSTEM")) col = Colors.grey;
          if (log.contains("AUTH")) col = Colors.cyan;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(log,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: col)),
          );
        },
      ),
    );
  }
}
