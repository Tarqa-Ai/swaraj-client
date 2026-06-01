import 'package:flutter/material.dart';
import '../../core/services/cache_service.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phoneNumber;

  const ProfileSetupScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _currentStep = 1;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  String _selectedClass = 'XII';
  String _selectedLanguage = 'English';
  final Set<String> _selectedInterests = {
    'Constitution',
    'Debates',
    'AI & Civics'
  };

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      await SwarajCacheService.saveUserProfile({
        'phoneNumber': widget.phoneNumber,
        'name': _nameController.text.trim().isEmpty
            ? 'Arjun K. Sharma'
            : _nameController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'school': _schoolController.text.trim().isEmpty
            ? "St. Xavier's Senior Sec."
            : _schoolController.text.trim(),
        'grade': _selectedClass,
        'language': _selectedLanguage,
        'interests': _selectedInterests.toList(),
        'points': 1452,
        'politicalIQ': 72,
        'streak': 14,
        'completedLessons': [
          'constitution-01',
          'government-01',
          'elections-01'
        ],
        'profileCompleted': true,
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
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    OutlinedButton(
                      onPressed: _prevStep,
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
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwarajColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
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
              style:
                  SwarajTypography.body(fontSize: 15, color: SwarajColors.navy),
              decoration: InputDecoration(
                hintText: 'e.g., Arjun K. Sharma',
                hintStyle: SwarajTypography.body(color: SwarajColors.outline),
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
            Text('DATE OF BIRTH', style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _dobController,
              readOnly: true,
              onTap: _selectDate,
              style:
                  SwarajTypography.body(fontSize: 15, color: SwarajColors.navy),
              decoration: InputDecoration(
                hintText: 'Select your birthday',
                hintStyle: SwarajTypography.body(color: SwarajColors.outline),
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
            Text('Your School', style: SwarajTypography.headline(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'This helps us connect you with classmates and your school leaderboard.',
              style: SwarajTypography.body(),
            ),
            const SizedBox(height: 36),
            Text('SCHOOL NAME', style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: _schoolController,
              style:
                  SwarajTypography.body(fontSize: 15, color: SwarajColors.navy),
              decoration: InputDecoration(
                hintText: "e.g., St. Xavier's Senior Sec.",
                hintStyle: SwarajTypography.body(color: SwarajColors.outline),
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
            Text('CLASS / GRADE', style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: ['IX', 'X', 'XI', 'XII'].map((grade) {
                final bool isSelected = _selectedClass == grade;
                return ChoiceChip(
                  label: Text(grade),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedClass = grade;
                      });
                    }
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
            Text('APP LANGUAGE', style: SwarajTypography.mono(fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['English', 'Hindi', 'Hinglish'].map((language) {
                final bool isSelected = _selectedLanguage == language;
                return ChoiceChip(
                  label: Text(language),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLanguage = language;
                      });
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
            Text('INTERESTS', style: SwarajTypography.mono(fontSize: 11)),
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
