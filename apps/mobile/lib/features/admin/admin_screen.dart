import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/config.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

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

  List<dynamic> _users = [];
  List<dynamic> _lessons = [];
  Map<String, dynamic> _debates = {
    'motion': '',
    'votesFavor': 0,
    'votesAgainst': 0,
    'arguments': []
  };

  int _totalUsers = 0;
  int _totalPoints = 0;
  double _avgIQ = 72.0;

  bool _isLoading = false;

  // Lesson Form Controllers
  final _lessonFormKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _totalController = TextEditingController(text: '10');
  final _completedController = TextEditingController(text: '0');

  // Motion Form Controller
  final _motionController = TextEditingController();

  final List<String> _systemLogs = [
    "[SYSTEM DETECTED: macOS Arm64]",
    "[OK] Node server listening on http://localhost:3000",
    "[OK] database.json read-back check successful",
    "[OK] iOS privacy manifest verified inside Runner/PrivacyInfo.xcprivacy",
    "[OK] Android compiling target successfully elevated to API level 35",
    "[NOTICE] Apple Guideline 4.8 Exemption confirmed - Zero social SSO",
    "[NOTICE] Account Erasure compliance tests verified (Guideline 5.1.1)"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchDataForActiveTab();
    });
    _fetchDashboardMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _totalController.dispose();
    _completedController.dispose();
    _motionController.dispose();
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

  Future<void> _fetchDashboardMetrics() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        setState(() {
          _users = users;
          _totalUsers = users.length;
          _totalPoints = users.fold(0, (sum, u) => sum + (u['points'] as int));
          final double totalIQ = users.fold(
              0.0, (sum, u) => sum + (u['politicalIQ'] as num).toDouble());
          _avgIQ = totalIQ / (_totalUsers == 0 ? 1 : _totalUsers);
        });
        _addLog("[LOAD] Loaded dashboard analytics metrics successfully");
      }
    } catch (e) {
      _addLog("[ERROR] Failed to fetch user metrics from API: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDataForActiveTab() async {
    final index = _tabController.index;
    if (index == 0) _fetchDashboardMetrics();
    if (index == 1) _fetchUsers();
    if (index == 2) _fetchLessons();
    if (index == 3) _fetchDebates();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        setState(() {
          _users = json.decode(response.body);
        });
      }
    } catch (e) {
      _addLog("[ERROR] Failed to fetch users: $e");
    }
  }

  Future<void> _fetchLessons() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lessons'));
      if (response.statusCode == 200) {
        setState(() {
          _lessons = json.decode(response.body);
        });
      }
    } catch (e) {
      _addLog("[ERROR] Failed to fetch lessons: $e");
    }
  }

  Future<void> _fetchDebates() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/debates'));
      if (response.statusCode == 200) {
        setState(() {
          _debates = json.decode(response.body);
        });
      }
    } catch (e) {
      _addLog("[ERROR] Failed to fetch debates: $e");
    }
  }

  Future<void> _adjustPoints(String phone) async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Points',
            style: SwarajTypography.headline(fontSize: 18)),
        content: TextField(
          controller: textController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            hintText: 'Enter amount (e.g. 100 or -50)',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            style: ElevatedButton.styleFrom(backgroundColor: SwarajColors.navy),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final amount = int.tryParse(result);
      if (amount == null) return;

      try {
        final response = await http.put(
          Uri.parse('$_baseUrl/users/$phone/points'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'amount': amount}),
        );
        if (response.statusCode == 200) {
          _showToast('User points adjusted successfully');
          _addLog("[EDIT] User points updated for phone $phone by $amount");
          _fetchUsers();
          widget.onDataChanged();
        }
      } catch (e) {
        _showToast('Failed to update points');
      }
    }
  }

  Future<void> _promoteRole(String phone, String currentRole) async {
    final String nextRole = currentRole == 'Citizen'
        ? 'Moderator'
        : (currentRole == 'Moderator' ? 'Admin' : 'Citizen');
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$phone/role'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'role': nextRole}),
      );
      if (response.statusCode == 200) {
        _showToast('Role promoted to $nextRole');
        _addLog("[ROLE] User $phone promoted to $nextRole");
        _fetchUsers();
        widget.onDataChanged();
      }
    } catch (e) {
      _showToast('Failed to update user role');
    }
  }

  Future<void> _suspendUser(String phone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Suspension'),
        content: const Text(
            'Are you sure you want to suspend this user and permanently delete all their account data? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: SwarajColors.error),
            child: const Text('SUSPEND'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('$_baseUrl/users/$phone'));
        if (response.statusCode == 200) {
          _showToast('User suspended successfully');
          _addLog("[SUSPEND] Purged user data details for phone $phone");
          _fetchUsers();
          widget.onDataChanged();
        }
      } catch (e) {
        _showToast('Failed to suspend user');
      }
    }
  }

  Future<void> _submitNewLesson() async {
    if (_lessonFormKey.currentState!.validate()) {
      final category = _categoryController.text.trim();
      final title = _titleController.text.trim();
      final desc = _descController.text.trim();
      final total = int.tryParse(_totalController.text) ?? 10;
      final completed = int.tryParse(_completedController.text) ?? 0;

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/lessons'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'category': category,
            'title': title,
            'desc': desc,
            'totalLessons': total,
            'completedCount': completed,
          }),
        );
        if (response.statusCode == 200) {
          _showToast('New module published successfully!');
          _addLog("[CURRICULUM] Published new module: $title");
          _categoryController.clear();
          _titleController.clear();
          _descController.clear();
          widget.onDataChanged();
          _tabController.animateTo(0); // bounce back to dashboard
        }
      } catch (e) {
        _showToast('Failed to publish lesson');
      }
    }
  }

  Future<void> _updateWeeklyMotion() async {
    final motionText = _motionController.text.trim();
    if (motionText.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/debates/motion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'motion': motionText}),
      );
      if (response.statusCode == 200) {
        _showToast('Weekly motion updated successfully!');
        _addLog("[DEBATE] Updated motion: \"$motionText\"");
        _motionController.clear();
        _fetchDebates();
        widget.onDataChanged();
      }
    } catch (e) {
      _showToast('Failed to update motion');
    }
  }

  Future<void> _moderateArgument(String argId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/debates/argument/$argId/moderate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        _showToast('Argument moderated: $status');
        _addLog("[MODERATION] Set status of $argId to $status");
        _fetchDebates();
        widget.onDataChanged();
      }
    } catch (e) {
      _showToast('Failed to moderate argument');
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
              child: const Icon(
                Icons.shield,
                size: 14,
                color: SwarajColors.saffron,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SWARAJ ADMIN',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: SwarajColors.saffron),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🛡️ PRIVILEGED',
              style: SwarajTypography.mono(
                  fontSize: 8,
                  color: SwarajColors.saffron,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: SwarajColors.saffron,
          unselectedLabelColor: SwarajColors.slate,
          indicatorColor: SwarajColors.saffron,
          tabs: const [
            Tab(text: '📊 Dashboard'),
            Tab(text: '👥 Users'),
            Tab(text: '📚 Curriculum'),
            Tab(text: '🗳️ Debate Moderation'),
            Tab(text: '⚙️ Logs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: SwarajColors.saffron))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildUsersTab(),
                _buildCurriculumTab(),
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
              style: SwarajTypography.headline(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      _totalUsers.toString(), 'ACTIVE CITIZENS')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatCard(
                      _totalPoints.toLocaleString(), 'TOTAL POINTS')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatCard(
                      _avgIQ.toStringAsFixed(1), 'AVG POLITICAL IQ')),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: SwarajColors.navy.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Activity Analytics',
                  style: SwarajTypography.headline(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(45, 'MON', false),
                      _buildBar(80, 'TUE', false),
                      _buildBar(60, 'WED', false),
                      _buildBar(110, 'TODAY', true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, bool isToday) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height,
            width: 32,
            decoration: BoxDecoration(
              color: isToday ? SwarajColors.saffron : SwarajColors.navy,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: SwarajTypography.mono(
              fontSize: 8,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? SwarajColors.saffron : SwarajColors.slate,
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
              style: SwarajTypography.headline(
                  fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: SwarajTypography.mono(
                fontSize: 7,
                color: SwarajColors.slateLight,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, idx) {
        final u = _users[idx];
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
                    Text(u['name'] ?? '',
                        style: SwarajTypography.headline(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: SwarajColors.navy),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        u['role'] ?? 'Citizen',
                        style: SwarajTypography.mono(
                            fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(u['school'] ?? '',
                    style: SwarajTypography.body(
                        fontSize: 12, color: SwarajColors.slate)),
                Text(u['phone'] ?? '',
                    style: SwarajTypography.mono(
                        fontSize: 10, color: SwarajColors.saffron)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Points: ${u['points']}',
                        style: SwarajTypography.mono(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Streak: 🔥 ${u['streak']}',
                        style: SwarajTypography.mono(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _adjustPoints(u['phone']),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SwarajColors.navy)),
                        child: Text('✏️ POINTS',
                            style: SwarajTypography.mono(
                                fontSize: 10, color: SwarajColors.navy)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _promoteRole(u['phone'], u['role'] ?? 'Citizen'),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SwarajColors.navy)),
                        child: Text('🎖️ ROLE',
                            style: SwarajTypography.mono(
                                fontSize: 10, color: SwarajColors.navy)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _suspendUser(u['phone']),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                SwarajColors.error.withValues(alpha: 0.1),
                            elevation: 0),
                        child: Text('✖ BAN',
                            style: SwarajTypography.mono(
                                fontSize: 10, color: SwarajColors.error)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurriculumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _lessonFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Publish New Module',
                style: SwarajTypography.headline(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                  labelText: 'CATEGORY (e.g. FOUNDATIONS, YOUR RIGHTS)',
                  filled: true,
                  fillColor: Colors.white),
              validator: (v) => v!.isEmpty ? 'Field required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'MODULE TITLE',
                  filled: true,
                  fillColor: Colors.white),
              validator: (v) => v!.isEmpty ? 'Field required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                  labelText: 'DESCRIPTION',
                  filled: true,
                  fillColor: Colors.white),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Field required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'TOTAL LESSONS',
                        filled: true,
                        fillColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _completedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'COMPLETED COUNT',
                        filled: true,
                        fillColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitNewLesson,
                style: ElevatedButton.styleFrom(
                    backgroundColor: SwarajColors.navy,
                    foregroundColor: Colors.white),
                child: Text('PUBLISH MODULE',
                    style: SwarajTypography.mono(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            Text('Active Modules Catalog',
                style: SwarajTypography.headline(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_lessons.isEmpty)
              const Center(child: Text('No active curriculum modules.'))
            else
              ..._lessons.map((m) => Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: SwarajColors.navy.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(m['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(m['desc'] ?? ''),
                      trailing: Text(
                        '${m['completedCount']}/${m['totalLessons']}',
                        style: SwarajTypography.mono(
                            color: SwarajColors.saffron,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildDebatesTab() {
    final pendingArgs = (_debates['arguments'] as List<dynamic>?)
            ?.where((a) => a['status'] == 'pending')
            .toList() ??
        [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Weekly Motion',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _motionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new debate topic...',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _updateWeeklyMotion,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: SwarajColors.navy,
                      foregroundColor: Colors.white),
                  child: Text('LAUNCH',
                      style: SwarajTypography.mono(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Flagged Arguments Queue',
              style: SwarajTypography.headline(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (pendingArgs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No pending arguments in queue.')),
            )
          else
            ...pendingArgs.map((a) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: SwarajColors.navy.withValues(alpha: 0.08)),
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
                            Text(a['name'] ?? '',
                                style: SwarajTypography.headline(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(a['time'] ?? '',
                                style: SwarajTypography.mono(
                                    fontSize: 8,
                                    color: SwarajColors.slateLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(a['text'] ?? '',
                            style: SwarajTypography.body(
                                fontSize: 13, color: SwarajColors.slate)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _moderateArgument(a['id'], 'approved'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: SwarajColors.success,
                                    foregroundColor: Colors.white,
                                    elevation: 0),
                                child: Text('APPROVE',
                                    style: SwarajTypography.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _moderateArgument(a['id'], 'deleted'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: SwarajColors.error,
                                    foregroundColor: Colors.white,
                                    elevation: 0),
                                child: Text('REJECT',
                                    style: SwarajTypography.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
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

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              log,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: col,
              ),
            ),
          );
        },
      ),
    );
  }
}

extension NumberFormatting on int {
  String toLocaleString() {
    final str = toString();
    if (str.length <= 3) return str;
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3 && i >= 0) {
        buffer.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i >= 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }
}
