import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SwarajCacheService {
  static SharedPreferences? _prefs;

  static const String _keyProfile = 'swaraj_user_profile';
  static const String _keyOfflinePoints = 'swaraj_offline_points_queue';

  /// Initialize local shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save the user profile loaded from network locally to disk
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    if (_prefs == null) return;
    await _prefs!.setString(_keyProfile, json.encode(profile));
  }

  /// Retrieve the locally cached user profile
  static Map<String, dynamic>? getUserProfile() {
    if (_prefs == null) return null;
    final jsonStr = _prefs!.getString(_keyProfile);
    if (jsonStr == null) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Queue points earned offline so they can be synchronized later when online
  static Future<void> queueOfflinePoints(int points) async {
    if (_prefs == null) return;
    final currentQueue = _prefs!.getInt(_keyOfflinePoints) ?? 0;
    await _prefs!.setInt(_keyOfflinePoints, currentQueue + points);

    // Optimistically update cached points; IQ is authoritative from server via GET /me
    final profile = getUserProfile();
    if (profile != null) {
      final currentPoints = (profile['points'] as num?)?.toInt() ?? 0;
      profile['points'] = currentPoints + points;
      await saveUserProfile(profile);
    }
  }

  /// Get the queue of points earned while offline
  static int getOfflinePointsQueue() {
    if (_prefs == null) return 0;
    return _prefs!.getInt(_keyOfflinePoints) ?? 0;
  }

  /// Reset/clear the queued offline points (after syncing with backend successfully)
  static Future<void> clearOfflinePointsQueue() async {
    if (_prefs == null) return;
    await _prefs!.remove(_keyOfflinePoints);
  }

  /// Clear all cached data (for Apple compliance Guideline 5.1.1 erasure)
  static Future<void> clearAll() async {
    if (_prefs == null) return;
    await _prefs!.clear();
  }
}
