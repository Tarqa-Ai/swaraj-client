import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _currentStep = 1;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _selectedClass = 'XII';
  String _selectedLanguage = 'en';
  final Set<String> _selectedInterests = {};

  List<Map<String, dynamic>> _schools = [];
  String? _selectedSchoolId;
  String _schoolSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await ref.read(apiClientProvider).get('/schools') as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _schools =
            data.map((s) => Map<String, dynamic>.from(s as Map)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load schools');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _canProceedStep1() =>
      _nameController.text.trim().length >= 2 && _dobController.text.isNotEmpty;

  bool _canProceedStep2() => _selectedSchoolId != null;

  bool _canProceedStep3() => _selectedLanguage.isNotEmpty;

  Future<void> _nextStep() async {
    if (_currentStep == 1 && !_canProceedStep1()) {
      setState(() => _error = 'Please enter your name and date of birth.');
      return;
    }
    if (_currentStep == 2 && !_canProceedStep2()) {
      setState(() => _error = 'Please select your school.');
      return;
    }
    setState(() => _error = null);

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      return;
    }

    await _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final gradeInt = int.tryParse(_selectedClass) ??
          {'IX': 9, 'X': 10, 'XI': 11, 'XII': 12}[_selectedClass]!;

      await ref.read(apiClientProvider).patch('/me/profile', {
        'name': _nameController.text.trim(),
        'grade': gradeInt,
        'schoolId': _selectedSchoolId!,
        'language': _selectedLanguage,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome to Swaraj!',
            style: SwarajTypography.mono(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: SwarajColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^.*?: '), '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _error = null;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008, 1, 1),
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SwarajColors.navy,
              onPrimary: Colors.white,
              onSurface: SwarajColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  List<Map<String, dynamic>> get _filteredSchools {
    if (_schoolSearchQuery.isEmpty) return _schools;
    final q = _schoolSearchQuery.toLowerCase();
    return _schools.where((s) {
      final name = (s['name'] as String? ?? '').toLowerCase();
      final district = (s['district'] as String? ?? '').toLowerCase();
      return name.contains(q) || district.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SwarajColors.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: MediaQuery.of(context).size.width *
                              (_currentStep / 3.0),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: SwarajColors.saffron,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'STEP $_currentStep OF 3',
                    style: SwarajTypography.mono(
                        fontSize: 11, color: SwarajColors.slateLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepContent(),
              ),
            ),
            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Text(
                  _error!,
                  style: SwarajTypography.body(
                      fontSize: 13, color: Colors.red.shade700),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        side: BorderSide(
                            color: SwarajColors.navy.withValues(alpha: 0.12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back,
                              size: 16, color: SwarajColors.navy),
                          const SizedBox(width: 8),
                          Text(
                            'BACK',
                            style: SwarajTypography.mono(
                                fontSize: 13, color: SwarajColors.navy),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwarajColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == 3 ? 'GET STARTED' : 'NEXT',
                                  style: SwarajTypography.mono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 16),
                              ],
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Your Details',
                style: SwarajTypography.headline(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'Tell us a bit about yourself to personalize your learning experience.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 8),
            Text(
              '"Building informed citizens, the foundation of a Viksit Bharat."',
              style: SwarajTypography.mono(
                fontSize: 10,
                color: SwarajColors.saffron,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 36),
            Text('FULL NAME', style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: SwarajTypography.body(
                  fontSize: 15, color: SwarajColors.navy),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle:
                    SwarajTypography.body(color: SwarajColors.outline),
                filled: true,
                fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('DATE OF BIRTH',
                style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _selectDate,
              style: SwarajTypography.body(
                  fontSize: 15, color: SwarajColors.navy),
              decoration: InputDecoration(
                hintText: 'Select your birthday',
                hintStyle:
                    SwarajTypography.body(color: SwarajColors.outline),
                suffixIcon: const Icon(Icons.calendar_today,
                    size: 18, color: SwarajColors.slateLight),
                filled: true,
                fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.all(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: SwarajColors.navy.withValues(alpha: 0.1)),
                ),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Your School',
                style: SwarajTypography.headline(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'This helps us connect you with classmates and your school leaderboard.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 36),
            Text('CLASS / GRADE',
                style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: ['IX', 'X', 'XI', 'XII'].map((grade) {
                final bool isSelected = _selectedClass == grade;
                return ChoiceChip(
                  label: Text(grade),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedClass = grade);
                  },
                  labelStyle: SwarajTypography.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : SwarajColors.navy,
                  ),
                  selectedColor: SwarajColors.navy,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? SwarajColors.navy
                          : SwarajColors.navy.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('SCHOOL NAME',
                style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              TextField(
                onChanged: (v) => setState(() => _schoolSearchQuery = v),
                style: SwarajTypography.body(
                    fontSize: 15, color: SwarajColors.navy),
                decoration: InputDecoration(
                  hintText: 'Search school by name or district',
                  hintStyle:
                      SwarajTypography.body(color: SwarajColors.outline),
                  prefixIcon:
                      const Icon(Icons.search, color: SwarajColors.slateLight),
                  filled: true,
                  fillColor: SwarajColors.navy.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: SwarajColors.navy.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_filteredSchools.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _schools.isEmpty
                        ? 'No schools available'
                        : 'No schools match your search',
                    style: SwarajTypography.body(color: SwarajColors.slate),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: SwarajColors.navy.withValues(alpha: 0.1)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredSchools.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: SwarajColors.navy.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final school = _filteredSchools[index];
                      final id = school['id'] as String;
                      final name = school['name'] as String? ?? '';
                      final district = school['district'] as String? ?? '';
                      final isSelected = _selectedSchoolId == id;
                      return InkWell(
                        onTap: () =>
                            setState(() => _selectedSchoolId = id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: isSelected
                              ? SwarajColors.saffron.withValues(alpha: 0.08)
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: SwarajTypography.body(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: SwarajColors.navy,
                                      ),
                                    ),
                                    if (district.isNotEmpty)
                                      Text(
                                        district,
                                        style: SwarajTypography.mono(
                                            fontSize: 11,
                                            color: SwarajColors.slateLight),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check,
                                    size: 18, color: SwarajColors.saffron),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Your Interests',
                style: SwarajTypography.headline(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'Choose your app language and topics for a personalized civic feed.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 36),
            Text('APP LANGUAGE',
                style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                {'label': 'English', 'value': 'en'},
                {'label': 'Hindi', 'value': 'hi'},
              ].map((lang) {
                final bool isSelected =
                    _selectedLanguage == lang['value'];
                return ChoiceChip(
                  label: Text(lang['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = lang['value']!);
                    }
                  },
                  labelStyle: SwarajTypography.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : SwarajColors.navy,
                  ),
                  selectedColor: SwarajColors.navy,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: isSelected
                          ? SwarajColors.navy
                          : SwarajColors.navy.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text('INTERESTS (OPTIONAL)',
                style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInterestChip('Constitution', Icons.gavel),
                _buildInterestChip('Elections', Icons.how_to_vote),
                _buildInterestChip('Debates', Icons.forum),
                _buildInterestChip('Policy & Law', Icons.article),
                _buildInterestChip('History', Icons.menu_book),
                _buildInterestChip('AI & Civics', Icons.psychology),
              ],
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildInterestChip(String name, IconData icon) {
    final bool isSelected = _selectedInterests.contains(name);
    return ChoiceChip(
      avatar: Icon(
        isSelected ? Icons.check : icon,
        size: 16,
        color: isSelected ? Colors.white : SwarajColors.navy,
      ),
      label: Text(name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(name);
          } else {
            _selectedInterests.remove(name);
          }
        });
      },
      labelStyle: SwarajTypography.body(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isSelected ? Colors.white : SwarajColors.navy,
      ),
      selectedColor: SwarajColors.navy,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected
              ? SwarajColors.navy
              : SwarajColors.navy.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      showCheckmark: false,
    );
  }
}
