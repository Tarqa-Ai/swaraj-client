import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/session_store.dart';

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(apiClientProvider), ref.read(sessionStoreProvider)));

class AuthRepository {
  AuthRepository(this._api, this._sessionStore);

  final ApiClient _api;
  final SessionStore _sessionStore;

  Future<void> sendOtp({required String email, required String phone}) async {
    await _sessionStore.savePhone(phone);
    await _sessionStore.saveEmail(email);
    await Supabase.instance.client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    await Supabase.instance.client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
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

  Future<Map<String, dynamic>> demoLogin() async {
    await _sessionStore.saveDemoToken('demo-token-123');
    await _sessionStore.saveEmail('demo@swaraj.local');
    await _sessionStore.savePhone('9876543210');
    final user = await _api.get('/me') as Map<String, dynamic>;
    final language = user['language'] as String?;
    if (language != null) await _sessionStore.saveLanguage(language);
    return user;
  }

  Future<void> logout() async {
    await _sessionStore.clear();
  }
}
