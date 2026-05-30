import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/presentation/ai_explain_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/certificate/presentation/certificate_screen.dart';
import '../../features/challenges/presentation/daily_challenge_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/debate/presentation/debate_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/learning/presentation/lesson_screen.dart';
import '../../features/learning/presentation/module_detail_screen.dart';
import '../../features/learning/presentation/modules_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((_) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/modules', builder: (_, __) => const ModulesScreen()),
      GoRoute(
        path: '/modules/:moduleId',
        builder: (_, state) => ModuleDetailScreen(moduleId: state.pathParameters['moduleId']!),
        routes: [
          GoRoute(
            path: 'lessons/:lessonId',
            builder: (_, state) => LessonScreen(
              moduleId: state.pathParameters['moduleId']!,
              lessonId: state.pathParameters['lessonId']!,
            ),
          ),
        ],
      ),
      GoRoute(path: '/quiz/:id', builder: (_, state) => QuizScreen(quizId: state.pathParameters['id']!)),
      GoRoute(path: '/challenge', builder: (_, __) => const DailyChallengeScreen()),
      GoRoute(path: '/debate', builder: (_, __) => const DebateScreen()),
      GoRoute(path: '/ai', builder: (_, __) => const AiExplainScreen()),
      GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/certificate', builder: (_, __) => const CertificateScreen()),
    ],
  );
});
