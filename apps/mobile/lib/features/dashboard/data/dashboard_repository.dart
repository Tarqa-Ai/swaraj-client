import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).cachedGet('/dashboard', cacheKey: 'dashboard'));
final modulesProvider = FutureProvider<List<dynamic>>((ref) => ref.read(apiClientProvider).cachedGet('/modules', cacheKey: 'modules'));
final dailyChallengeProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/daily-challenge'));
final leaderboardProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).get('/leaderboard'));
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) => ref.read(apiClientProvider).cachedGet('/me', cacheKey: 'profile'));
