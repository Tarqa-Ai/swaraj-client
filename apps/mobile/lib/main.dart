import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'core/config/config.dart';
import 'core/services/cache_service.dart';
import 'core/constants/colors.dart';
import 'core/widgets/bottom_nav.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/profile_setup_screen.dart';
import 'features/dashboard/home_screen.dart';
import 'features/learning/learn_screen.dart';
import 'features/learning/lesson_screen.dart';
import 'features/debate/debate_screen.dart';
import 'features/ai_assistant/ai_chat_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/cert_locked_screen.dart';
import 'features/profile/certificate_detail_screen.dart';
import 'features/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SwarajCacheService.init();
  runApp(const SwarajApp());
}

class SwarajApp extends StatelessWidget {
  const SwarajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swaraj — Civic Learning Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SwarajColors.cream,
      ),
      initialRoute: '/onboarding',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/otp':
            final String phone = settings.arguments as String? ?? '98765 43210';
            return MaterialPageRoute(
                builder: (_) => OtpScreen(phoneNumber: phone));
          case '/setup':
            final args = settings.arguments as Map<String, dynamic>?;
            final phone = args?['phoneNumber'] as String? ?? '9876543210';
            return MaterialPageRoute(
                builder: (_) => ProfileSetupScreen(phoneNumber: phone));
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const NavigationShell());
          case '/lesson':
            return MaterialPageRoute(builder: (_) => const LessonScreen());
          case '/cert-locked':
            return MaterialPageRoute(builder: (_) => const CertLockedScreen());
          case '/certificate':
            return MaterialPageRoute(
                builder: (_) => const CertificateDetailScreen());
          case '/admin':
            return MaterialPageRoute(
              builder: (_) => AdminScreen(
                onDataChanged: () {
                  // Dynamic rebuild notification callback
                },
              ),
            );
          default:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        }
      },
    );
  }
}

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  int _points = 12;

  @override
  void initState() {
    super.initState();
    _loadCachedPoints();
  }

  void _loadCachedPoints() {
    final profile = SwarajCacheService.getUserProfile();
    if (profile != null) {
      setState(() {
        _points = profile['points'] ?? 12;
      });
    }
  }

  void _addPoints(int amount) {
    setState(() {
      _points += amount;
    });
    // Queue offline points instantly on local disk cache
    SwarajCacheService.queueOfflinePoints(amount);

    // Trigger online background synchronization
    _syncPointsOnline(amount);
  }

  Future<void> _syncPointsOnline(int amount) async {
    try {
      final response = await http
          .put(
            Uri.parse('${SwarajConfig.apiBaseUrl}/users/9876543210/points'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'amount': amount}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await SwarajCacheService.saveUserProfile(data);
        await SwarajCacheService.clearOfflinePointsQueue();
      }
    } catch (e) {
      debugPrint(
          'Swaraj offline active points synced locally. Server sync postponed: $e');
    }
  }

  void _onTabSelect(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onTabChange: _onTabSelect, points: _points),
      LearnScreen(
        onTabChange: _onTabSelect,
        points: _points,
        onPointsEarned: _addPoints,
      ),
      DebateScreen(onTabChange: _onTabSelect, points: _points),
      const AIChatScreen(),
      ProfileScreen(
        onTabChange: _onTabSelect,
        points: _points,
        onResetAllData: () async {
          await SwarajCacheService.clearAll();
          setState(() {
            _points = 12;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: SwarajColors.cream,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SwarajBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelect,
      ),
    );
  }
}
