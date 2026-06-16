import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/session_store.dart';
// ignore: unused_import — Supabase kept for signOut in logout()

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(apiClientProvider), ref.read(sessionStoreProvider)));

// Test account — bypasses the backend entirely; backend accepts the hardcoded token.
const _testEmail = 'sudhanshutiwari264@gmail.com';
const _testOtp = '123456';
const _testDevToken = 'swaraj-dev-bypass-264';

class AuthRepository {
  AuthRepository(this._api, this._sessionStore);

  final ApiClient _api;
  final SessionStore _sessionStore;

  Future<void> sendOtp({required String email, required String phone}) async {
    await _sessionStore.savePhone(phone);
    await _sessionStore.saveEmail(email);
    if (email == _testEmail) return;
    await _api.post('/auth/send-otp', {'email': email, 'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    if (email == _testEmail && code == _testOtp) {
      // Dev bypass — use hardcoded token, no Supabase session needed for testing
      ApiClient.setDevToken(_testDevToken);
    } else {
      // Backend verifies OTP and returns a custom signed JWT for the student
      final result = await _api.post('/auth/verify-otp', {'email': email, 'code': code})
          as Map<String, dynamic>;
      final accessToken = result['access_token'] as String;

      // Persist and activate so all API calls are authenticated across restarts
      await _sessionStore.saveToken(accessToken);
      ApiClient.setDevToken(accessToken);
    }

    final user = await _api.get('/me') as Map<String, dynamic>;
    final language = user['language'] as String?;
    if (language != null) await _sessionStore.saveLanguage(language);
    return user;
  }

  Future<Map<String, dynamic>?> me() async {
    try {
      return await _api.get('/me') as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    ApiClient.clearDevToken();
    await _sessionStore.clear();
  }
}
