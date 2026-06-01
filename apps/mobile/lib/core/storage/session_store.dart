import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionStoreProvider = Provider<SessionStore>((_) => SessionStore());

class SessionStore {
  static const _storage = FlutterSecureStorage();
  static const _keyPhone = 'swaraj_phone';
  static const _keyEmail = 'swaraj_email';
  static const _keyLanguage = 'swaraj_language';
  static const _keyDemoToken = 'swaraj_demo_token';

  Future<void> savePhone(String phone) =>
      _storage.write(key: _keyPhone, value: phone);
  Future<String?> getPhone() => _storage.read(key: _keyPhone);

  Future<void> saveEmail(String email) =>
      _storage.write(key: _keyEmail, value: email);
  Future<String?> getEmail() => _storage.read(key: _keyEmail);

  Future<void> saveLanguage(String language) =>
      _storage.write(key: _keyLanguage, value: language);
  Future<String?> getLanguage() => _storage.read(key: _keyLanguage);

  Future<void> saveDemoToken(String token) =>
      _storage.write(key: _keyDemoToken, value: token);
  Future<String?> getDemoToken() => _storage.read(key: _keyDemoToken);

  Future<void> clear() async {
    await _storage.deleteAll();
    await Supabase.instance.client.auth.signOut();
  }
}
