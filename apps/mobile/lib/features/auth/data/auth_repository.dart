import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/session_store.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(apiClientProvider), ref.read(sessionStoreProvider)));
final authStateProvider = StateProvider<bool>((_) => false);

class AuthRepository {
  AuthRepository(this._api, this._sessionStore);

  final ApiClient _api;
  final SessionStore _sessionStore;

  Future<void> sendOtp(String phone) => _api.post('/auth/send-otp', {'phone': phone});

  Future<void> verifyOtp({required String phone, required String code}) async {
    final result = await _api.post<Map<String, dynamic>>('/auth/verify-otp', {'phone': phone, 'code': code});
    await _sessionStore.saveTokens(accessToken: result['accessToken'] as String, refreshToken: result['refreshToken'] as String);
  }

  Future<void> logout() => _sessionStore.clear();
}
