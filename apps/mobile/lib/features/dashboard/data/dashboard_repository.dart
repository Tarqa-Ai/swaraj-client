import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/dashboard'));
final modulesProvider = FutureProvider<List<dynamic>>((ref) => ref.read(apiClientProvider).get('/modules'));
final dailyChallengeProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/daily-challenge'));
final currentDebateProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/debate/current'));
final leaderboardProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/leaderboard'));
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/me'));
