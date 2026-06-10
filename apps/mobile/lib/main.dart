import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/cache_service.dart';
import 'core/api/api_client.dart';
import 'core/storage/session_store.dart';
import 'core/constants/colors.dart';
import 'core/widgets/bottom_nav.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/profile_setup_screen.dart';
import 'features/dashboard/home_screen.dart';
import 'features/learning/learn_screen.dart';
import 'features/learning/lesson_screen.dart';
import 'features/learning/module_detail_screen.dart';
import 'features/learning/quiz_screen.dart';
import 'features/debate/debate_screen.dart';
import 'features/ai_assistant/ai_chat_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/cert_locked_screen.dart';
import 'features/profile/certificate_detail_screen.dart';
import 'features/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SwarajCacheService.init();
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://mocwoshzlcbwbjgsdctd.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vY3dvc2h6bGNid2JqZ3NkY3RkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyODg1MDQsImV4cCI6MjA5NTg2NDUwNH0.baIJrQJoUVX0XpjOMxh5VaELTxQ38lOZfB7dY53SHYw',
    ),
  );
  runApp(const ProviderScope(child: SwarajApp()));
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
            final String email = settings.arguments as String? ?? '';
            return MaterialPageRoute(builder: (_) => OtpScreen(email: email));
          case '/setup':
            final args = settings.arguments as Map<String, dynamic>?;
            final phone = args?['phoneNumber'] as String? ?? '';
            return MaterialPageRoute(
                builder: (_) => ProfileSetupScreen(phoneNumber: phone));
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const NavigationShell());
          case '/module':
            final moduleArgs = settings.arguments as Map?;
            final moduleId = moduleArgs?['moduleId'] as String? ?? '';
            return MaterialPageRoute(
                builder: (_) => ModuleDetailScreen(moduleId: moduleId));
          case '/lesson':
            final lessonArgs = settings.arguments as Map?;
            final lessonId = lessonArgs?['lessonId'] as String? ?? '';
            final moduleId = lessonArgs?['moduleId'] as String? ?? '';
            return MaterialPageRoute(
                builder: (_) =>
                    LessonScreen(lessonId: lessonId, moduleId: moduleId));
          case '/quiz':
            final quizArgs = settings.arguments as Map?;
            final quizData =
                (quizArgs?['quiz'] as Map<String, dynamic>?) ?? {};
            final quizModuleId = quizArgs?['moduleId'] as String? ?? '';
            return MaterialPageRoute(
                builder: (_) =>
                    QuizScreen(quiz: quizData, moduleId: quizModuleId));
          case '/cert-locked':
            return MaterialPageRoute(builder: (_) => const CertLockedScreen());
          case '/certificate':
            return MaterialPageRoute(
                builder: (_) => const CertificateDetailScreen());
          case '/ai-chat':
            return MaterialPageRoute(builder: (_) => const AIChatScreen());
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

class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({super.key});

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  int _currentIndex = 0;
  int _points = 0;
  int _homeRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _loadCachedPoints();
  }

  void _loadCachedPoints() {
    final profile = SwarajCacheService.getUserProfile();
    if (profile != null) {
      setState(() {
        _points = (profile['points'] as num?)?.toInt() ?? 0;
      });
    }
  }

  void _addPoints(int amount) {
    setState(() {
      _points += amount;
    });
    SwarajCacheService.queueOfflinePoints(amount);
    _syncPointsOnline(amount);
  }

  Future<void> _syncPointsOnline(int amount) async {
    final phone = await ref.read(sessionStoreProvider).getPhone();
    if (phone == null || phone.isEmpty) return;
    try {
      final data = await ref
          .read(apiClientProvider)
          .put('/users/$phone/points', {'amount': amount}) as Map<String, dynamic>?;
      if (data != null) {
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
      if (index == 0) _homeRefreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onTabChange: _onTabSelect, points: _points, refreshToken: _homeRefreshToken),
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
          await ref.read(sessionStoreProvider).clear();
          setState(() {
            _points = 0;
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
