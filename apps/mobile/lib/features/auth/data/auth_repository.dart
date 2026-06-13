import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/session_store.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(apiClientProvider), ref.read(sessionStoreProvider)));

// Test account — bypasses Supabase entirely; backend accepts the hardcoded token.
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
    await Supabase.instance.client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    if (email == _testEmail && code == _testOtp) {
      await _sessionStore.saveDevToken(_testDevToken);
    } else {
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );
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
    await _sessionStore.clear();
  }
}
