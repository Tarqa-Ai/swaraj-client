import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/session_store.dart';

final schoolsProvider = FutureProvider<List<dynamic>>((ref) => ref.read(apiClientProvider).get('/schools'));
final onboardingControllerProvider = StateNotifierProvider<OnboardingController, AsyncValue<void>>(
  (ref) => OnboardingController(
    ref.read(apiClientProvider),
    ref.read(sessionStoreProvider),
    ref.read(localeProvider.notifier),
  ),
);

class OnboardingController extends StateNotifier<AsyncValue<void>> {
  OnboardingController(this._api, this._sessionStore, this._localeController) : super(const AsyncData(null));

  final ApiClient _api;
  final SessionStore _sessionStore;
  final LocaleController _localeController;

  Future<Map<String, dynamic>> saveProfile({
    required String name,
    required String language,
    required int grade,
    required String schoolId,
  }) async {
    state = const AsyncLoading();
    try {
      final profile = await _api.patch<Map<String, dynamic>>('/me/profile', {
        'name': name,
        'language': language,
        'grade': grade,
        'schoolId': schoolId,
      });
      await _sessionStore.saveLanguage(language);
      await _localeController.setLocale(language);
      state = const AsyncData(null);
      return profile;
    } catch (err, stack) {
      state = AsyncError(err, stack);
      rethrow;
    }
  }
}
